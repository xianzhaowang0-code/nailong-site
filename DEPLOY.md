# 济南奶龙职业技术学院.icu 部署笔记

## 一、域名基本信息

| 项目 | 值 |
|---|---|
| 中文域名 | 济南奶龙职业技术学院.icu |
| Punycode | `xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu` |
| 注册商 | Alibaba Cloud Computing Ltd. d/b/a HiChina（阿里云 / 万网） |
| 注册时间 | 2026-10-14T03:09:17Z |
| 到期时间 | 2027-10-14T23:59:59Z |
| 登记 NS | dns23.hichina.com / dns24.hichina.com（阿里云默认解析） |

Punycode 由本地计算得出，并与注册局 RDAP 返回的 `ldhName` 逐字符一致。
浏览器访问中文域名时，会自动转换成 punycode 再去查询 DNS，所以**云解析里要填 punycode 形式**（阿里云控制台通常允许直接粘贴中文域名，会自动转）。

## 二、当前状态（2026-10-14 03:26Z 复查）

### 已解决 ✓ 过户生效，client hold 解除

RDAP 状态变化：

```
之前: ['server transfer prohibited', 'client hold', 'client renew prohibited',
       'client transfer prohibited', 'add period']
现在: ['server transfer prohibited', 'add period']
```

`client hold` 已消失，`last changed` 更新为 2026-10-14T03:21:34Z。过户确认生效。

### 已解决 ✓ 注册局委派已恢复（2026-10-14 03:37Z 复查）

```
a.nic.icu (194.169.218.108): rcode=NOERROR
    AUTHORITY: dns23.hichina.com.
    AUTHORITY: dns24.hichina.com.
```

rcode 由 `NXDOMAIN` 变为 `NOERROR`，且 AUTHORITY 段返回了 NS 委派。
四个公共解析器全部正常返回。

> **踩坑记录**：TLD 对委派的应答放在 **AUTHORITY** 段，不是 ANSWER 段。
> 只在 ANSWER 段找 NS 会得到假阴性。判断委派是否恢复看 **rcode** 更可靠：
> `NXDOMAIN` = 无委派，`NOERROR` = 有委派。

### 部分完成 △ A 记录只填了 1 条，缺 3 条

```
实际返回: ['185.199.108.153']
缺失    : ['185.199.109.153', '185.199.110.153', '185.199.111.153']
```

单条可用，但 GitHub 建议四条齐全以实现轮询与容灾。

### 未解决 ✗ GitHub 上还没有站点

```
HTTP  : 404  title: Site not found · GitHub Pages
HTTPS : 证书 CN = *.github.io —— 不匹配本域名
```

A 记录已把流量正确送到 GitHub Pages，但 GitHub 上还没有仓库把该域名设为
自定义域名，所以返回 404，证书仍是通配 `*.github.io`。

**注意**：`Site not found · GitHub Pages` 本身是好消息——它证明整条 DNS 链路
已经打通，只差托管端配置。

## 三、现在要做的事

### 立刻可做：去云解析加记录（不用等委派恢复）

阿里云控制台 → 云解析 DNS → 找到 `济南奶龙职业技术学院.icu` → 解析设置 → 添加记录。

⚠️ **主机记录填 `@`，不是 punycode 全串。**
主机记录是相对于域名的**前缀**，裸域（apex）用 `@` 表示。
若填 punycode 全串，会生成
`xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu`
这样一个根本不存在、也不会被访问的子域——**填了等于没填**。

正确填法：

```
记录类型: A
主机记录: @
记录值  : 185.199.108.153
TTL     : 600
```

其余三个 IP 各加一条（主机记录同为 `@`，多条 A 记录可共存）。完整清单见第四节。

### 待办 1：补齐三条 A 记录

同一个 `@` 下再加三条：

```
185.199.109.153
185.199.110.153
185.199.111.153
```

### 待办 2：在 GitHub 建站

1. 新建仓库，放入 `index.html` 和 `CNAME`
   （本目录已备好 `CNAME`，内容为 punycode 域名）
2. 仓库 Settings → Pages → Source 选分支 → Custom domain 填
   `xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu`
3. 等 GitHub 签发 HTTPS 证书（通常几分钟到 1 小时），再勾选 Enforce HTTPS

### 已完成

- [x] 过户 —— RDAP 状态已确认
- [x] 实名认证成功（阿里云短信通知，含域名实名/过户/转入）
- [x] `client hold` 解除
- [x] 注册局恢复 NS 委派
- [x] A 记录 `185.199.108.153` 已生效，DNS 链路打通

> 参考：[阿里云：解除域名 Clienthold / Serverhold 状态](https://help.aliyun.com/zh/dws/support/how-to-unlock-a-domain-name-that-is-in-the-serverhold-or-clienthold-state)、[域名被暂停解析了，如何恢复解析？](https://help.aliyun.com/zh/dns/ymztyxjx)

## 四、解析配置（已按官方文档核实）

`index.html` 已就绪，是不依赖任何外部资源的单文件占位页。

**关键前提**：域名是**裸域（apex）**，不是 `www` 子域。这决定了记录类型——
apex 上的 CNAME 和 A 记录是**互斥**的，且不同托管商对 apex 的要求完全不同。

### 路线 A：GitHub Pages + 阿里云 A 记录（不用动 NS，推荐先试这条）

GitHub 官方文档：apex 域名要建 **A 记录**（不是 CNAME）。

| 记录类型 | 主机记录 | 解析线路 | 记录值 | TTL |
|---|---|---|---|---|
| A | `@` | 默认 | `185.199.108.153` | 600 |
| A | `@` | 默认 | `185.199.109.153` | 600 |
| A | `@` | 默认 | `185.199.110.153` | 600 |
| A | `@` | 默认 | `185.199.111.153` | 600 |

> 四条记录的「主机记录」都是 `@`（同一个裸域配多条 A 记录，属正常做法）。
> 阿里云云解析的 A 记录之间标记为「可重复」，允许共存。

可选 IPv6（AAAA，GitHub 建议同时保留 A 记录）：

```
2606:50c0:8000::153
2606:50c0:8001::153
2606:50c0:8002::153
2606:50c0:8003::153
```

配套动作：仓库根目录放 `CNAME` 文件，内容 `xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu`；
仓库 Settings → Pages 填入同一域名（务必用 punycode）。

> GitHub Pages 对非 ASCII 自定义域名有已知兼容问题，中文形式可能导致校验失败。

### 路线 B：Cloudflare Pages（apex 必须把 NS 迁到 Cloudflare）

Cloudflare 官方文档原文：*"To deploy your Pages project to a custom apex domain,
that custom domain must be a zone on the Cloudflare account you have created your
Pages project on."*

即**裸域必须把域名 NS 指向 Cloudflare**，Cloudflare 才会自动创建 CNAME。

- 要回阿里云把 NS 从 `dns23/dns24.hichina.com` 改成 Cloudflare 分配的两个 NS
- 改完之后**阿里云云解析失效**，解析全部在 Cloudflare 管
- 记录值由 Cloudflare 自动生成，**不需要手填**

若不想动 NS，只能走子域：`www.xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu`
CNAME 到 `<项目名>.pages.dev`，但裸域仍需另行处理。

### 路线 C：阿里云 OSS 香港节点（无需备案，国内访问快）

境内节点必须 ICP 备案，**香港节点不需要**。适合想要国内速度又不想备案的情况，
代价是少量存储/流量费用。

### 附：阿里云云解析的 CNAME@ 规则

据云解析[记录冲突规则](https://www.alibabacloud.com/help/zh/dns/pubz-dns-record-conflict-rules)：
主机记录为 `@` 时，CNAME 与 MX、TXT **不再冲突**（官方特殊处理），
但与 **A、AAAA、ALIAS、URL 冲突**。所以 `@` 上的 CNAME 可以配，
只是不能与 A 记录共存——**这就是为什么路线 A 和路线 B 不能混用。**

### 重要提醒：备案与访问速度

- 走 Cloudflare Pages / GitHub Pages 属**境外托管，无需 ICP 备案**，但国内访问速度一般，且稳定性不保证
- 若将来要迁到阿里云 OSS / ECS 等**境内节点**，则必须完成 **ICP 备案**（需境内服务器、周期以周计），这是另一道独立的门槛
- 中文域名在微信、QQ 等 App 内粘贴/跳转时，部分场景识别不佳，建议同时准备 punycode 链接

## 五、解锁后的验证

```bash
# 1) 查状态，应为 ok 或仅 clientTransferProhibited，不应再有 client hold
curl -sL "https://rdap.org/domain/xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu" | python3 -m json.tool | grep -A6 status

# 2) 查解析，应返回 IP 或 CNAME，而不是 NXDOMAIN
python3 -c "import socket;print(socket.getaddrinfo('xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu',None))"

# 3) 查 HTTP 与证书
curl -sI "https://xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu"
```

## 六、GitHub Pages 建站实测记录（含一次被推翻的错误结论）

2026-10-14 在电脑端实际建站的过程与证据。

### 症状

仓库建好、Pages 开启后，前两次构建失败：

```
pages.status   = errored
build.status   = errored
build.error    = "Page build failed."
build.duration = 0
```

站点在自定义域名和 `xianzhaowang0-code.github.io/nailong-site/` 上**都**返回 404。

### ⚠️ 一个被推翻的结论（保留作为教训）

当时的排查：把仓库里的 `CNAME` 文件删掉、并清空 Pages 的 cname 设置后，构建成功了。
于是当场得出结论「**`CNAME` 文件在 punycode 域名上会导致构建失败**」，并写进了本笔记。

**这个结论是错的。** 后来的对照测试推翻了它：

| commit | 仓库里有 CNAME 文件 | 构建结果 |
|---|---|---|
| `c2c51c9` | 有 | errored, errored ← **唯一真正的失败** |
| `83dd988` | **无** | errored(dur=0) + **built**(dur=46185) |
| `828f9dd` | 有 | errored(dur=0) + **built**(dur=26289) |
| `828f9dd`（重新触发） | 有 | **built**(dur=20042) |

两个关键反证：

1. `83dd988` **没有** `CNAME` 文件，却同样出现了一条 `errored / dur=0` 的构建。
   → 这条 `errored / dur=0` 是**伴随产生的噪音构建**，不代表失败。
   真正的失败特征是「两次构建全部 errored，没有任何 built」。
2. `828f9dd` **有** `CNAME` 文件，构建成功；重新触发一次仍然成功。

### 排查方法上的错误

第一次「隔离实验」同时改动了**两个**变量：

- 删掉 `CNAME` 文件
- 清空 Pages 的自定义域名设置

而且两次操作之间隔了约 4 分钟 —— 这期间用户正好把**剩余三条 A 记录补齐了**。
所以「删 CNAME 之后就好了」是**混淆变量**导致的假因果。正确做法是一次只改一个变量。

### 最可能的原因

初始两次失败发生在 Pages 刚开启后的头几秒，且当时自定义域名的 DNS 只配了
**1 条 A 记录（缺 3 条）**。DNS 未就绪 + Pages 刚启用，两者叠加导致构建失败。
A 记录补齐、Pages 完成初始化后，构建恢复正常，**与 `CNAME` 文件无关**。

> 诚实说明：没有再做「故意把 DNS 改坏以复现失败」的实验，
> 所以「DNS 未就绪是唯一原因」这一点属于**推断**，不是实测结论。
> 但「`CNAME` 文件导致失败」这一点已被上表**明确证伪**。

### 现在的正确做法

`CNAME` 文件是 GitHub Pages 的官方做法，本项目**保留它**，内容为 punycode 域名。

```bash
# 开启 Pages, 源 = main 分支根目录
POST /repos/:owner/:repo/pages
{ "source": { "branch": "main", "path": "/" } }

# 设置自定义域名 (punycode) —— 无 CNAME 文件时用这个
PUT  /repos/:owner/:repo/pages
{ "cname": "xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu" }

# 证书签发后强制 HTTPS
PUT  /repos/:owner/:repo/pages
{ "https_enforced": true }
```

> **注意**：一旦在网页端 Settings → Pages 里设置过自定义域名，
> GitHub 会**自动补一个 `CNAME` 文件**，commit message 为 `Create CNAME`。
> 这是正常行为，不要删。

### 顺带记录（这些是确认无误的）

- 第一次 `git push` 遇到 `502`，但 `ls-remote` 正常 → 属**偶发**，重试即可，不是权限问题
- 推送时用 `git -c http.extraheader="Authorization: Basic <base64>"`，
  token **不写进 `.git/config`**，避免明文落盘
- 用经典 token 时 `repo` 是父级、必须整体勾选；
  只勾子项 `repo: status` 拿不到建仓库 / 推送 / 配 Pages 的权限
- 细粒度 token（`github_pat_` 开头）**没有创建仓库的权限**，`POST /user/repos` 返回 403
- 阿里云 DNS 的 TTL 缓存会让各公共解析器进度不一：
  A 记录补齐后，`1.1.1.1` / `8.8.8.8` 立刻见四条，`223.5.5.5` 仍返回旧的一条，最长 600 秒
