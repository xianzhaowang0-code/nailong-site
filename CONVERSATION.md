# 对话记录与工作交接：济南奶龙职业技术学院.icu 部署

> 生成时间：2026-10-14T03:40Z
> 生成环境：Android 手机容器（DeepSeek Harness）
> 用途：转移到电脑上继续后续部署工作

---

## 一、当前状态速览

| 环节 | 状态 |
|---|---|
| 域名注册 | ✅ 完成（阿里云 / 万网） |
| 过户 | ✅ 完成 |
| 实名认证 | ✅ 完成（阿里云短信通知确认） |
| `client hold` | ✅ 已解除 |
| 注册局 NS 委派 | ✅ 已恢复 |
| DNS A 记录 | △ **只填了 1 条，缺 3 条** |
| GitHub Pages 站点 | ❌ **尚未创建** |
| HTTPS 证书 | ❌ 仍是 `*.github.io` 通配证书 |

**一句话**：DNS 链路已完全打通，流量能正确抵达 GitHub Pages，只差在 GitHub 上把站点建起来。

---

## 二、域名基础信息

| 项目 | 值 |
|---|---|
| 中文域名 | 济南奶龙职业技术学院.icu |
| Punycode | `xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu` |
| 注册商 | Alibaba Cloud Computing Ltd. d/b/a HiChina（阿里云 / 万网） |
| 注册时间 | 2026-10-14T03:09:17Z |
| 到期时间 | 2027-10-14T23:59:59Z |
| 登记 NS | `dns23.hichina.com` / `dns24.hichina.com` |
| 权威服务器 IP | dns23 = `120.76.107.60`，dns24 = `39.96.153.61` |
| SOA serial | `2026101411` |
| RDAP 查询 | https://rdap.org/domain/xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu |

Punycode 由本地计算得出，与注册局 RDAP 返回的 `ldhName` **逐字符一致**。

---

## 三、关键时间线

| UTC 时间 | 事件 |
|---|---|
| 03:09:17 | 域名注册 |
| 03:14:48 | 首次检测：`client hold` 状态，全部解析器 NXDOMAIN |
| 03:21:34 | 过户生效，`client hold` 解除（RDAP last changed） |
| 03:26:28 | 复查：hold 已解除，但注册局委派未恢复，zone 内零记录 |
| ~03:37 | 实名认证成功（阿里云短信通知） |
| 03:37:52 | 委派已恢复；A 记录 `185.199.108.153` 已生效；HTTP 返回 GitHub Pages 404 |

---

## 四、对话记录

### 第 1 轮

**用户**：我在阿里云注册了一个前面是中文的.icu 域名，你可以帮我部署一下吗？

**处理**：先做环境侦察，不臆测。

- 容器环境：有 node/npm/pnpm/python3/git/curl/openssl；**没有** nginx、docker、cloudflared、frp、ngrok
- 网络：GitHub / Cloudflare / npm / PyPI 均可达（HTTP 200）
- 工作区 `/sdcard/123321`：杂项文件，无现成站点项目
- 明确告知：阿里云账号我无访问权，域名实名与云解析必须用户本人操作

**结论**：信息不足，提问补齐。

### 第 2 轮

**用户回答**：
- 域名：`济南奶龙职业技术学院.icu`
- 内容：暂时没有，只想先把域名解析好、能打开
- 托管：Cloudflare Pages / GitHub Pages 这类免费托管

**处理**：计算 punycode → `xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu`（label 长 36，上限 63，合法）

RDAP 查出注册局状态：

```
status: ['server transfer prohibited', 'client hold',
         'client renew prohibited', 'client transfer prohibited',
         'add period']
```

DNS 实测四个公共解析器全部 NXDOMAIN。

**结论**：`client hold` 意味着阿里云已在注册局层面撤销 NS 委派。此时配置解析无效，**任何部署都是白做**。

### 第 3 轮

**用户**：还没有过户成功

**处理**：确认了这个说法与 `client hold` 吻合，成因判断为「实名认证未完成」或「过户流程中」。给出阿里云解锁清单。

同时创建了部署产物：`index.html`（占位页）、`DEPLOY.md`。

### 第 4 轮

**用户**：这个域名可能构成侵权吗

**处理**：查证后给出风险分析，两个独立风险点：

**风险一：「奶龙」**
- 受著作权保护的动漫美术作品，权利方为**第七印象**（官网 nailoong.com）
- 有商标注册（「奶龙益智乐园」等已获准注册），在商标异议案件中被作为在先权利主张
- 维权活跃，有盗版奶龙被诉的法院判例
- 域名中「奶龙」是显著性最强的部分 → 可能构成商标侵权或反不正当竞争

**风险二：「济南」+「职业技术学院」**
- 设立高等职业学校、民办学校需审批，校名有规范
- 域名形似真实学校官网（真实存在济南职业学院、济南工程职业技术学院等），具备误导性
- 有假冒高校网站招生的判例

**风险取决于用途而非注册**：

| 做法 | 风险 |
|---|---|
| 只注册持有、不建站 | 较低，但权利人可走争议程序 |
| 建站但明确标注玩梗 | 较低，不为零 |
| 使用奶龙形象做宣传 | 高 |
| 涉及招生、收费、发证 | 极高，可能触及诈骗 |
| 广告、带货等商业目的 | 高 |

**追责机制**：`.icu` 是 gTLD，适用 **ICANN 的 UDRP**（非 CNNIC 规则）。权利人只要证明①域名与商标混淆性相似 ②无合法权益 ③注册使用具恶意，即可申请**直接判走域名**。阿里云作为注册商必须执行裁决。

**关键提醒**：域名需实名到本人，**没有匿名空间**。

### 第 5 轮

**用户**：那世界奶龙大学.com 为什么没有事

**处理**：实测该域名，发现它具备一组用户**不具备**的条件。

实测结果：

| 项目 | 实测值 |
|---|---|
| 注册商 | **GoDaddy.com, LLC**（美国，非国内注册商） |
| 注册时间 | 2026-10-12T12:55:48Z（**仅 2 天**） |
| 状态 | 全部 `client * prohibited`（GoDaddy 保护锁），**无 `client hold`** |
| NS | NS57/NS58.DOMAINCONTROL.COM |
| 解析 | 3.33.251.168 / 15.197.225.128（AWS AS16509） |
| 内容 | 服务器返回 **301 → `https://drise.dlut.edu.cn`**（大连理工大学中日国际软件学院） |
| 服务头 | `Server: ip-100-74-5-26.eu-west-2.compute.internal` |

**它"没事"的四个具体原因**：

1. 才注册 2 天，权利人可能还不知道
2. 注册商在境外（GoDaddy 不受中国监管约束，维权需走 UDRP 或美国诉讼，成本高周期长）
3. 不承载内容，纯 301 转发，属最低限度使用
4. **跳向真站而非冒充真站**——访客最终看到真实官网，不存在"以为在上假学校"的混淆

这是「奶龙/奶蛙大学」玩梗潮的一部分（国立奶龙大学跳兰州大学、南京奶龙大学、中国奶蛙大学等）。

**关键对比**：该域名的安全边际来自「境外注册商 + 零内容 + 纯跳转 + 刚注册」，用户的情况是它的反面（境内注册商 + 自建内容 + 独立站点 + 实名到本人）。且**「奶龙」商标风险两边相同**，真正不同的是**被追究的概率与代价**。另外这是**生存者偏差**——被 UDRP 判走、被关站的域名不会出现在视野里。

### 第 6 轮

**用户**：那如果我被阿里云驳回了，会怎么样

**处理**：分环节说明后果。

| 环节被驳回 | 后果 |
|---|---|
| 实名认证被驳回 | 可重新提交（换清晰证件照、核对姓名证件号），非一次判死。持续不通过则一直 `client hold`，最终到期注销 |
| 命名审核不通过 | 部分后缀注册局有命名审核，不通过通常域名被删除，费用可退 |
| 过户被驳回 | 域名仍在原持有人名下。平台担保交易一般退款；私下交易需自行追讨 |

阿里云域名注册后**一般不支持无理由退款**，仅注册失败或注册局删除可退。
另说明：**阿里云不会因"可能侵权"主动驳回注册**——侵权是民事问题，需权利人主张。

### 第 7 轮

**用户**：上面好像显示过户成功了

**处理**：实测确认。

```
之前: ['server transfer prohibited', 'client hold', 'client renew prohibited',
       'client transfer prohibited', 'add period']
现在: ['server transfer prohibited', 'add period']
```

`client hold` 消失，`last changed` = 03:21:34Z。**过户确认生效。**

但当时：
- 注册局仍返回 NXDOMAIN（委派未恢复）
- zone 内零记录（A/AAAA/CNAME/MX/TXT 全无，仅 NS + SOA）

### 第 8 轮

**用户**：记录值是多少

**处理**：核实官方文档后发现**三处此前写错的地方**，修正：

1. **域名是裸域（apex），不是 www 子域** → GitHub Pages 裸域要 **A 记录**，不是 CNAME
2. **Cloudflare Pages 裸域必须把 NS 迁到 Cloudflare**（官方原文：*"To deploy your Pages project to a custom apex domain, that custom domain must be a zone on the Cloudflare account..."*），记录值由 Cloudflare 自动生成，无需手填
3. 阿里云云解析 `@` 上的 CNAME 与 A/AAAA/ALIAS/URL **冲突**，两者不能混用

**GitHub Pages 官方 IP**（已核实）：
- A：`185.199.108.153`、`185.199.109.153`、`185.199.110.153`、`185.199.111.153`
- AAAA：`2606:50c0:8000::153`、`2606:50c0:8001::153`、`2606:50c0:8002::153`、`2606:50c0:8003::153`

### 第 9 轮

**用户**：解析记录值怎么填写

**处理**：发现并修正**自己写的一个实质性错误**。

❌ 之前写的：`主机记录: xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it`
✅ 正确：`主机记录: @`

阿里云官方原文：*「主机记录 通常指子域名的**前缀**，系统会自动拼接主域名。**请勿填写完整域名**，否则会导致解析…」*

填 punycode 全串会生成
`xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu`
这样一个不存在的子域，**等于白填**。

官方同时确认：*「一个主机记录可添加多个A记录值，实现DNS轮询负载均衡。每条记录值算作一条独立的解析记录。」* → 同一个 `@` 下挂四条 A 记录是正常做法。

### 第 10 轮

**用户**：贴出阿里云短信——实名认证成功（含域名实名、过户、转入），并提示备案需等 3 天同步。

**处理**：实测复查，发现状态大幅推进：

**委派已恢复**：
```
a.nic.icu (194.169.218.108): rcode=NOERROR
    AUTHORITY: dns23.hichina.com.
    AUTHORITY: dns24.hichina.com.
```

**A 记录只填了 1 条**：
```
实际返回: ['185.199.108.153']
缺失    : ['185.199.109.153', '185.199.110.153', '185.199.111.153']
```

**站点仍打不开**：
```
HTTP  : 404   title: Site not found · GitHub Pages
HTTPS : 证书 CN = *.github.io —— 不匹配本域名
```

**关键解读**：`Site not found · GitHub Pages` 是**好消息**——证明 A 记录已生效、流量已正确抵达 GitHub Pages，只是 GitHub 上还没有仓库认领该域名。证书仍是通配 `*.github.io` 也是同一原因。

**同时纠正了我自己的一次误判**：TLD 对委派的应答放在 **AUTHORITY** 段而非 ANSWER 段，只在 ANSWER 段找 NS 会得到**假阴性**。判断委派是否恢复，看 `rcode` 更可靠：`NXDOMAIN` = 无委派，`NOERROR` = 有委派。

---

## 五、技术要点与踩坑记录

### 1. `client hold` 的语义
阿里云在**注册局层面撤销 NS 委派**。此时云解析里加任何记录都不生效。RDAP 里列出的 NS 只是登记信息，不代表生效。**这不是"解析没配好"，配解析解决不了。**

### 2. 委派恢复与状态位解除是两件事
`client hold` 从 RDAP status 消失（03:21）后，注册局委派直到 03:37 才恢复。注册局重建区文件是周期性的，通常几小时，最长 24 小时。

### 3. 判断委派是否恢复：看 rcode，别只看 ANSWER 段
```
NXDOMAIN = 无委派
NOERROR  = 有委派（NS 委派在 AUTHORITY 段）
```

### 4. 裸域 vs 子域决定记录类型
| 托管 | 裸域要求 | 记录类型 |
|---|---|---|
| GitHub Pages | A 记录（官方明确） | A |
| Cloudflare Pages | 必须把 NS 迁到 Cloudflare | 自动生成 CNAME |

### 5. 阿里云云解析 `主机记录` 语义
填**前缀**，系统自动拼主域名。裸域用 `@`。**切勿填完整域名。**

### 6. `@` 上的记录冲突规则
据[云解析记录冲突规则](https://www.alibabacloud.com/help/zh/dns/pubz-dns-record-conflict-rules)：
- `@` 上 CNAME 与 **MX、TXT 不冲突**（官方特殊处理）
- `@` 上 CNAME 与 **A、AAAA、ALIAS、URL 冲突**
- → 这就是为什么 GitHub（A 记录）和 Cloudflare（CNAME）两条路**不能混用**

### 7. 备案
- GitHub Pages / Cloudflare Pages 属**境外托管，无需 ICP 备案**
- 迁到阿里云 OSS/ECS **境内节点**才需备案（需境内服务器、周期按周计）
- 阿里云 OSS **香港节点不需要备案**，是国内速度与免备案的折中（路线 C）

### 8. 负缓存
`.icu` 的负缓存 TTL 为 3600 秒（1 小时）。委派恢复后公共解析器可能还需最多 1 小时才返回正确结果。

---

## 六、待办事项（在电脑上完成）

### 待办 1：补齐三条 A 记录

阿里云控制台 → 云解析 DNS → 公网权威解析 → `济南奶龙职业技术学院.icu` → 解析设置 → 添加记录

同一个 `@` 下再加三条：

```
主机记录: @
记录类型: A
记录值  : 185.199.109.153
```
```
主机记录: @
记录类型: A
记录值  : 185.199.110.153
```
```
主机记录: @
记录类型: A
记录值  : 185.199.111.153
```

**完整四条应如下**：

| 记录类型 | 主机记录 | 解析线路 | 记录值 | TTL |
|---|---|---|---|---|
| A | @ | 默认 | 185.199.108.153 | 600 |
| A | @ | 默认 | 185.199.109.153 | 600 |
| A | @ | 默认 | 185.199.110.153 | 600 |
| A | @ | 默认 | 185.199.111.153 | 600 |

**常见填错**：
- ❌ 记录值带 `https://` 或端口 → 只填纯 IP
- ❌ 记录类型选成 CNAME → 裸域 CNAME 与 A 记录冲突
- ❌ 主机记录填完整域名 → 填 `@`
- ❌ 在错误的域名下操作 → 确认顶部选中的是 `济南奶龙职业技术学院.icu`

### 待办 2：在 GitHub 建站

1. 新建仓库，上传 `index.html` 与 `CNAME`（本包内已备好）
   - `CNAME` 文件名**全大写、无扩展名**，内容为 `xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu`
2. 仓库 Settings → Pages → Source 选分支
3. Custom domain 填 `xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu`（**务必用 punycode**）
4. 等 GitHub 签发 HTTPS 证书（几分钟到 1 小时），再勾选 **Enforce HTTPS**

> GitHub Pages 对非 ASCII 自定义域名有已知兼容问题，务必用 punycode 形式。

### 待办 3：验证部署

```bash
D=xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu

# 1) A 记录是否四条齐全
python3 -c "
import dns.resolver
r=dns.resolver.Resolver(configure=False); r.nameservers=['223.5.5.5']
print(sorted(str(x) for x in r.resolve('$D','A')))
"

# 2) HTTP 状态与标题
curl -sIL "https://$D/" | head -20

# 3) 证书是否匹配域名
openssl s_client -connect "$D:443" -servername "$D" </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates
```

**通过标准**：
- A 记录返回四个 IP
- HTTP 200，页面标题为「济南奶龙职业技术学院」
- 证书 `subject` 为本域名（不再是 `*.github.io`）

### 待办 4（决策）：内容风险

域名已到手，**放什么内容才是决定风险的那一步**。若只是玩梗，建议：
- 页面明确标注「这是一个玩笑域名，与任何真实学校无关，与奶龙 IP 权利方无关」
- **不要**使用奶龙的任何卡通形象、图片、logo
- **不要**声称是真实学校，也不要暗示与济南市教育部门有关
- 不用于任何商业目的，不涉及招生收费
- 收到权利人通知及时配合

> 非法律意见。若打算认真运营（尤其涉及教育、收费），建议找知识产权律师做正式评估。

---

## 七、本包文件清单

| 文件 | 说明 |
|---|---|
| `index.html` | 占位页，单文件、零外部依赖，已实测 HTTP 200 正常返回 |
| `CNAME` | GitHub Pages 自定义域名文件，内容为 punycode 域名 |
| `DEPLOY.md` | 完整部署笔记（含全部实测证据与踩坑记录） |
| `CONVERSATION.md` | 本文件，对话记录与工作交接 |

---

## 八、命令速查

```bash
D=xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu

# RDAP 注册状态
curl -sL "https://rdap.org/domain/$D" | python3 -m json.tool

# 中文转 punycode
python3 -c "import codecs,unicodedata as u;print('xn--'+codecs.encode(u.normalize('NFC','济南奶龙职业技术学院'),'punycode').decode())"

# 问阿里云权威服务器（绕过公网缓存）
python3 -c "
import dns.resolver
r=dns.resolver.Resolver(configure=False); r.nameservers=['120.76.107.60']
for t in ['A','NS','SOA']:
    try: print(t, [str(x) for x in r.resolve('$D',t)])
    except Exception as e: print(t, type(e).__name__)
"

# 委派状态（看 rcode）
python3 -c "
import dns.resolver,dns.query,dns.message,dns.rdatatype,dns.rcode
ip=dns.resolver.resolve('a.nic.icu','A')[0].to_text()
resp=dns.query.udp(dns.message.make_query('$D',dns.rdatatype.NS),ip,timeout=8)
print('rcode =', dns.rcode.to_text(resp.rcode()))
print('AUTHORITY =', [rr.to_text() for rs in resp.authority for rr in rs])
"
```

---

*本文档由 Android 容器内的 DeepSeek Harness 会话生成，所有技术结论均来自实测，非推测。*
