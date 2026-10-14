# 济南奶龙职业技术学院.icu

> Jinan Nailong Vocational & Technical College — 一个玩笑域名站点

Punycode：`xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu`
仓库：https://github.com/xianzhaowang0-code/nailong-site

---

## 这个仓库是什么

一个**零依赖、零构建**的静态站点，托管在 GitHub Pages 上。

| 文件 | 作用 |
|---|---|
| `index.html` | 单文件占位页，无任何外部请求 |
| `.nojekyll` | 阻止 GitHub Pages 走 Jekyll 构建 |
| `verify.ps1` | Windows 端部署验证脚本 |
| `DEPLOY.md` | 部署笔记（DNS / 备案 / 记录冲突规则） |
| `CONVERSATION.md` | 从手机端转来的对话记录与交接说明 |

> ⚠️ **本仓库中不要出现 `CNAME` 文件。** 原因见下一节，这是实测踩到的坑。

---

## ⚠️ 关键坑：`CNAME` 文件会让构建失败

GitHub Pages 官方的自定义域名做法是在仓库根目录放一个 `CNAME` 文件。
**在 IDN / punycode 域名上，这个做法会让构建直接失败。**

实测对照（同一仓库、同一份内容、同一个域名）：

| 自定义域名的配置方式 | 构建结果 |
|---|---|
| 仓库根目录放 `CNAME` 文件，内容为 punycode 域名 | ❌ `status=errored`，`build.status=errored`，`Page build failed.`，`duration=0` |
| 删除 `CNAME` 文件，改用 **Pages 设置**（`PUT /repos/:owner/:repo/pages`，或网页 Settings → Pages） | ✅ `build.status=built`，`duration=26289ms` |

失败时 `duration` 恒为 `0`，即构建任务根本没跑起来 —— 不是内容问题，是域名处理环节的问题。
同一个仓库在不设自定义域名时（走 `xianzhaowang0-code.github.io/nailong-site/`）
构建完全正常，进一步排除了内容侧的原因。

**结论**：punycode 域名走 Pages 设置配置，不要放 `CNAME` 文件。
`verify.ps1` 的第 5 节会检查并阻止 `CNAME` 文件被提交。

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
（含「不应存在 `CNAME` 文件」这一条）。退出码 `0` 表示全部通过。

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
