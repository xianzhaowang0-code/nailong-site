# 济南奶龙职业技术学院.icu

> Jinan Nailong Vocational & Technical College — 一个玩笑域名站点

Punycode：`xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu`
仓库：https://github.com/xianzhaowang0-code/nailong-site

---

## 这个仓库是什么

一个**零依赖、零构建**的静态站点，托管在 GitHub Pages 上。

| 文件 | 作用 |
|---|---|
| `index.html` | 首页（零依赖静态页面） |
| `assets/css/style.css` | 全部样式，无外部字体 / 无 CDN |
| `assets/js/main.js` | 轮播、移动端菜单、院系搜索过滤、滚动高亮 |
| `assets/img/` | 校徽、校园照、形象大使、favicon |
| `CNAME` | GitHub Pages 自定义域名（由 Pages 设置自动创建） |
| `.nojekyll` | 阻止 GitHub Pages 走 Jekyll 构建 |
| `verify.ps1` | Windows 端部署验证脚本 |
| `DEPLOY.md` | 部署笔记（DNS / 备案 / 记录冲突规则 / 踩坑记录） |
| `CONVERSATION.md` | 从手机端转来的对话记录与交接说明 |

### 页面结构

公告条 → 顶栏 → 头部（校徽 + 搜索）→ 导航 → 首屏轮播 → 学校概况 →
院系设置（支持搜索过滤）→ 校园风光 → 友情链接 → 页脚免责声明

> `CNAME` 文件（内容为 punycode 域名）由 GitHub 在网页端
> Settings → Pages 设置自定义域名时自动创建，commit message 为 `Create CNAME`，属正常行为。

---

## 建站时的一段弯路（当时的结论已被推翻，保留作教训）

首次构建失败（`Page build failed.`，`duration=0`），当时把原因归到仓库里的
`CNAME` 文件上，并据此改了文档和验证脚本。**这个结论是错的。**

后来的对照测试把它证伪了：

| commit | 仓库里有 `CNAME` 文件 | 构建结果 |
|---|---|---|
| `c2c51c9` | 有 | errored, errored ← **唯一真正的失败** |
| `83dd988` | **无** | errored(0s) + **built**(46s) |
| `828f9dd` | 有 | errored(0s) + **built**(26s) |
| `828f9dd`（重新触发） | 有 | **built**(20s) |

两个反证：

1. `83dd988` **没有** `CNAME` 文件，却同样出现 `errored / dur=0`
   → 那条只是**伴随产生的噪音构建**，不是失败标志。真正的失败是「全部 errored，没有任何 built」。
2. `828f9dd` **有** `CNAME` 文件，构建成功，重新触发仍然成功。

**排查方法上的错误**：第一次「隔离实验」同时改了**两个**变量（删 `CNAME` 文件 +
清空自定义域名设置），而且中间隔了约 4 分钟 —— 这期间 A 记录正好被补齐。
所以「删 CNAME 之后就好了」是**混淆变量**造成的假因果。

**最可能的原因**：初始失败发生在 Pages 刚开启、自定义域名只配了 1 条 A 记录的时候，
DNS 未就绪叠加初始化。A 记录补齐后构建即恢复正常，与 `CNAME` 文件无关。

> 诚实说明：「DNS 未就绪是唯一原因」属**推断**（没有做故意改坏 DNS 的复现实验）；
> 但「`CNAME` 文件导致失败」已被上表**明确证伪**。完整记录见 `DEPLOY.md` 第六节。

---

## 当前状态（实测）

| 环节 | 状态 |
|---|---|
| 域名注册 / 过户 / 实名 | ✅ 完成 |
| `client hold` 解除 | ✅ RDAP status 仅剩 `server transfer prohibited, add period` |
| 注册局 NS 委派 | ✅ `dns23/dns24.hichina.com` |
| DNS A 记录 | ✅ **四条齐全**（`185.199.108–111.153`） |
| GitHub Pages 站点 | ✅ `pages.status = built`，HTTP 200 |
| Custom domain | ✅ `xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu`（经 Pages 设置） |
| HTTPS 证书 | 见下方实测输出 |

---

## 验证

```powershell
powershell -ExecutionPolicy Bypass -File .\verify.ps1
```

五项检查：A 记录四条齐全、NS 委派、HTTP 状态、证书是否匹配本域名、仓库文件自检
（含 `CNAME` 文件内容是否与域名一致）。退出码 `0` 表示全部通过。

> 注意：本脚本含中文，必须保存为 **UTF-8 带 BOM**。
> Windows PowerShell 5.1 若按 GBK 读取会直接报语法错误。

---

## 内容风险提醒

「奶龙」是受著作权保护的动漫美术作品，权利方为第七印象（nailoong.com），且有商标注册；
「济南」+「职业技术学院」形似真实学校校名。`.icu` 是 gTLD，适用 ICANN 的 **UDRP**，
权利人可申请直接判走域名。域名实名到本人，**没有匿名空间**。

若只是玩梗，建议：

- 页面明确标注「玩笑域名，与任何真实学校无关，与奶龙 IP 权利方无关」
- **不要**使用奶龙的卡通形象、图片、logo
- **不要**声称是真实学校，不要暗示与济南市教育部门有关
- 不用于商业目的，不涉及招生收费
- 收到权利人通知及时配合

> 以上非法律意见。若打算认真运营（尤其涉及教育、收费），请找知识产权律师做正式评估。
