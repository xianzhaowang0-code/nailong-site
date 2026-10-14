#Requires -Version 5.1
<#
  济南奶龙职业技术学院.icu —— 部署验证脚本 (Windows / PowerShell)

  用法 (Windows PowerShell 5.1 或 PowerShell 7 均可):
      powershell -ExecutionPolicy Bypass -File .\verify.ps1
      powershell -ExecutionPolicy Bypass -File .\verify.ps1 -Domain <域名>

  注意: 本文件含中文, 必须保存为 "UTF-8 带 BOM"。
        Windows PowerShell 5.1 若按 GBK 读取会报语法错误。

  退出码: 0 = 全部通过, 1 = 有未通过项
#>
[CmdletBinding()]
param(
    [string]$Domain = 'xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu'
)

try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$expectedA = @(
    '185.199.108.153', '185.199.109.153', '185.199.110.153', '185.199.111.153'
)
$fail = 0

function Write-Section([string]$Title) { Write-Host "`n=== $Title ===" -ForegroundColor Cyan }
function Write-Pass([string]$Msg)      { Write-Host "  [PASS] $Msg" -ForegroundColor Green }
function Write-Fail([string]$Msg)      { Write-Host "  [FAIL] $Msg" -ForegroundColor Red; $script:fail++ }
function Write-Info([string]$Msg)      { Write-Host "  [info] $Msg" -ForegroundColor DarkGray }

Write-Host "目标域名: $Domain" -ForegroundColor White

# ---------------------------------------------------------------- 1. A 记录
Write-Section '1. A 记录 (四条 GitHub Pages 官方 IP)'
foreach ($ns in @('223.5.5.5', '1.1.1.1', '8.8.8.8')) {
    try {
        $got = @(Resolve-DnsName -Name $Domain -Type A -Server $ns -DnsOnly -ErrorAction Stop |
                 Where-Object { $_.IPAddress } | ForEach-Object { $_.IPAddress } | Sort-Object -Unique)
        $missing = @($expectedA | Where-Object { $got -notcontains $_ })
        if ($missing.Count -eq 0) {
            Write-Pass "$ns -> 四条齐全 ($($got -join ', '))"
        }
        else {
            Write-Fail "$ns -> 只有 $($got.Count) 条: $($got -join ', '); 缺: $($missing -join ', ')"
        }
    }
    catch {
        Write-Fail "$ns -> 查询失败: $($_.Exception.Message)"
    }
}

# ------------------------------------------------------------------- 2. NS
Write-Section '2. NS 委派'
try {
    $ns = @(Resolve-DnsName -Name $Domain -Type NS -Server 223.5.5.5 -DnsOnly -ErrorAction Stop |
            Where-Object { $_.NameHost } | ForEach-Object { $_.NameHost } | Sort-Object -Unique)
    if ($ns.Count -gt 0) {
        Write-Pass "已委派: $($ns -join ', ')"
        Write-Info '若此处 NXDOMAIN, 说明注册局未委派 (查 RDAP status 是否含 client hold)'
    }
    else { Write-Fail '未返回 NS 记录' }
}
catch { Write-Fail "NS 查询失败: $($_.Exception.Message)" }

# ----------------------------------------------------------------- 3. HTTP
Write-Section '3. HTTP 响应'
$httpCode = $null
try {
    $resp = Invoke-WebRequest -Uri "http://$Domain/" -MaximumRedirection 5 -TimeoutSec 25 -UseBasicParsing
    $httpCode = [int]$resp.StatusCode
    $title = [regex]::Match($resp.Content, '<title>(.*?)</title>', 'Singleline').Groups[1].Value
    Write-Info "status = $httpCode"
    Write-Info "title  = $title"
}
catch {
    $r = $_.Exception.Response
    if ($r) {
        $httpCode = [int]$r.StatusCode
        Write-Info "status = $httpCode $($r.StatusDescription)"
    }
    else { Write-Fail "请求异常: $($_.Exception.Message)" }
}

if ($httpCode -eq 200) {
    Write-Pass 'HTTP 200'
}
elseif ($httpCode -eq 404) {
    Write-Fail 'HTTP 404 —— GitHub 上还没有仓库认领该域名 (DNS 链路本身是通的)'
}
elseif ($null -ne $httpCode) {
    Write-Fail "HTTP $httpCode"
}

# ---------------------------------------------------------------- 4. HTTPS
Write-Section '4. HTTPS 证书'
$tcp = $null; $ssl = $null
try {
    $tcp = [System.Net.Sockets.TcpClient]::new()
    $tcp.Connect($Domain, 443)
    $ssl = [System.Net.Security.SslStream]::new(
        $tcp.GetStream(), $false,
        [System.Net.Security.RemoteCertificateValidationCallback] { param($a, $b, $c, $d) $true })
    $ssl.AuthenticateAsClient($Domain)

    $cert   = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($ssl.RemoteCertificate)
    $dnsName = $cert.GetNameInfo(
        [System.Security.Cryptography.X509Certificates.X509NameType]::DnsName, $false)

    Write-Info "subject = $($cert.Subject)"
    Write-Info "issuer  = $($cert.Issuer)"
    Write-Info "notAfter= $($cert.NotAfter.ToUniversalTime().ToString('u'))"

    if ($cert.Subject -match '\*\.github\.io' -or $dnsName -match '\*\.github\.io') {
        Write-Fail '证书仍是 *.github.io 通配证书 —— GitHub 尚未为该域名签发证书'
    }
    elseif ($dnsName -eq $Domain -or $cert.Subject -match [regex]::Escape($Domain)) {
        Write-Pass "证书已匹配本域名 ($dnsName)"
    }
    else {
        Write-Fail "证书不含本域名: $dnsName"
    }
}
catch { Write-Fail "TLS 连接失败: $($_.Exception.Message)" }
finally {
    if ($ssl) { $ssl.Dispose() }
    if ($tcp) { $tcp.Dispose() }
}

# ------------------------------------------------------- 5. 本仓库文件自检
Write-Section '5. 本仓库文件'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$cnamePath = Join-Path $here 'CNAME'
if (Test-Path -LiteralPath $cnamePath) {
    $cname = (Get-Content -LiteralPath $cnamePath -Raw).Trim()
    if ($cname -eq $Domain) { Write-Pass "CNAME 内容正确: $cname" }
    else { Write-Fail "CNAME 内容为 '$cname', 与域名不符" }
}
else { Write-Fail 'CNAME 文件缺失' }

foreach ($f in @('index.html', '.nojekyll')) {
    if (Test-Path -LiteralPath (Join-Path $here $f)) { Write-Pass "$f 存在" }
    else { Write-Fail "$f 缺失" }
}

# ------------------------------------------------------------------- 汇总
Write-Host ''
if ($fail -eq 0) {
    Write-Host '全部通过 —— 部署完成。' -ForegroundColor Green
    exit 0
}
Write-Host "$fail 项未通过。" -ForegroundColor Yellow
exit 1
