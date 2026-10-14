# 济南奶龙职业技术学院.icu

> Jinan Nailong Vocational & Technical College — 一个玩笑域名站点

Punycode：`xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu`

---

## 这个仓库是什么

一个**零依赖、零构建**的静态站点，用于 GitHub Pages。
仓库根目录的 `CNAME` 文件（全大写、无扩展名）就是 GitHub Pages 的自定义域名声明。

| 文件 | 作用 |
|---|---|
| `index.html` | 单文件占位页，无任何外部请求 |
| `CNAME` | GitHub Pages 自定义域名（punycode 形式） |
| `.nojekyll` | 阻止 GitHub Pages 走 Jekyll 构建 |
| `verify.ps1` | Windows 端部署验证脚本 |
| `DEPLOY.md` | 完整部署笔记（含实测证据） |
| `CONVERSATION.md` | 从手机端转来的对话记录与交接说明 |

---

## 当前状态（实测）

| 环节 | 状态 |
|---|---|
| 域名注册 / 过户 / 实名 | ✅ 完成 |
| `client hold` 解除 | ✅ RDAP status 仅剩 `server transfer prohibited, add period` |
| 注册局 NS 委派 | ✅ `dns23/dns24.hichina.com` |
| DNS A 记录 | ⚠️ **只填了 1 条，缺 3 条** |
| GitHub Pages 站点 | ❌ **尚未创建**（HTTP 404 `Site not found · GitHub Pages`） |
| HTTPS 证书 | ❌ 仍是 `*.github.io` 通配证书 |

`Site not found · GitHub Pages` 说明 DNS 链路已经打通，流量确实抵达了 GitHub Pages —— 只差托管端配置。

---

## 剩下的两步

### 第 1 步：阿里云云解析补齐三条 A 记录

控制台 → 云解析 DNS → `济南奶龙职业技术学院.icu` → 解析设置 → 添加记录。
**主机记录填 `@`**（不要填 punycode 全串），同一个 `@` 下四条 A 记录共存：

| 记录类型 | 主机记录 | 记录值 | TTL |
|---|---|---|---|
| A | `@` | `185.199.108.153` | 600 |
| A | `@` | `185.199.109.153` | 600 |
| A | `@` | `185.199.110.153` | 600 |
| A | `@` | `185.199.111.153` | 600 |

### 第 2 步：把这个仓库推上 GitHub 并开启 Pages

```powershell
# 在 github.com 新建一个空仓库（不要勾选 README / .gitignore），然后：
git remote add origin https://github.com/<你的用户名>/<仓库名>.git
git push -u origin main
```

推送后在仓库里配置：

1. **Settings → Pages → Source** 选 `Deploy from a branch`，分支 `main`，目录 `/ (root)`
2. **Custom domain** 填 `xn--vhq90kl3fz5byvotjhjqlnj2b9s4b3it.icu`（**必须用 punycode**，中文形式 GitHub 校验会失败）
3. 等 GitHub 签发证书（几分钟到 1 小时），再勾选 **Enforce HTTPS**

---

## 验证

```powershell
powershell -ExecutionPolicy Bypass -File .\verify.ps1
```

检查五项：A 记录四条齐全、NS 委派、HTTP 200、证书匹配本域名、仓库文件自检。
退出码 `0` 表示全部通过。

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
