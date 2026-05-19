<#ftl output_format="HTML">
<#assign expirationText = "">
<#attempt>
  <#assign expirationText = linkExpirationFormatter(linkExpiration)>
<#recover>
  <#assign expirationText = "">
</#attempt>

<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <meta http-equiv="x-ua-compatible" content="ie=edge">
  <title>${msg("resetTitle")}</title>
</head>
<body style="margin:0;padding:0;background:#eef2f7;font-family:Arial,Helvetica,sans-serif;color:#253466;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#eef2f7;margin:0;padding:32px 12px;">
    <tr><td align="center">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:620px;background:#ffffff;border-radius:18px;overflow:hidden;border:1px solid #dfe6f1;box-shadow:0 10px 28px rgba(37,52,102,0.14);">
        <tr>
          <td style="background:#ffffff;padding:30px 32px 22px;text-align:center;border-bottom:4px solid #253466;">
            <img src="${url.resourcesUrl}/img/logo_papalini.png" width="260" alt="${msg('companyName')}" style="display:inline-block;max-width:260px;width:100%;height:auto;border:0;outline:none;text-decoration:none;">
          </td>
        </tr>
        <tr>
          <td style="padding:34px 36px 22px 36px;">
            <h1 style="margin:0 0 14px 0;font-size:25px;line-height:1.25;color:#253466;font-weight:700;">${msg("resetTitle")}</h1>
            <p style="margin:0 0 14px 0;font-size:16px;line-height:1.6;color:#3d4668;">Ciao,</p>
            <p style="margin:0 0 14px 0;font-size:16px;line-height:1.6;color:#3d4668;">${msg("resetIntro")} <strong style="color:#253466;">${realmName!msg("companyName")}</strong>.</p>
            <p style="margin:0 0 22px 0;font-size:16px;line-height:1.6;color:#3d4668;">${msg("resetHelp")}</p>
            <table role="presentation" cellpadding="0" cellspacing="0" style="margin:28px 0 26px 0;">
              <tr><td align="center" bgcolor="#253466" style="border-radius:10px;">
                <a href="${link!''}" style="display:inline-block;padding:14px 28px;font-size:15px;font-weight:700;line-height:1.2;color:#ffffff;text-decoration:none;border-radius:10px;background:#253466;text-transform:uppercase;letter-spacing:.04em;">${msg("resetButton")}</a>
              </td></tr>
            </table>
            <p style="margin:0 0 12px 0;font-size:14px;line-height:1.6;color:#5a6383;">${msg("resetExpiration")} <strong>${expirationText}</strong>.</p>
            <p style="margin:0 0 18px 0;font-size:14px;line-height:1.6;color:#5a6383;">${msg("resetIgnore")}</p>
            <div style="margin:24px 0 0 0;padding:16px;background:#f4f7fb;border-radius:12px;border:1px solid #dfe6f1;">
              <p style="margin:0 0 8px 0;font-size:13px;line-height:1.5;color:#68718f;">${msg("resetFallback")}</p>
              <a href="${link!''}" style="font-size:13px;line-height:1.5;color:#253466;word-break:break-all;text-decoration:none;">${link!''}</a>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding:22px 36px 30px 36px;background:#f9fafc;border-top:1px solid #e7ecf4;">
            <p style="margin:0 0 8px 0;font-size:13px;line-height:1.6;color:#68718f;">${msg("resetFooter")}</p>
            <p style="margin:0;font-size:13px;line-height:1.6;color:#68718f;"><strong>${msg("companyName")}</strong><br>${msg("companyAddress")}<br>${msg("companyPhone")} · <a href="mailto:${msg('companyEmail')}" style="color:#253466;text-decoration:none;">${msg("companyEmail")}</a><br><a href="${msg('companyWebsite')}" style="color:#253466;text-decoration:none;">${msg("companyWebsite")}</a></p>
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>
