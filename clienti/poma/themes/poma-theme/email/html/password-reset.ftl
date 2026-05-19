<#import "template.ftl" as layout>
<@layout.emailLayout>
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:0;padding:0;background:#eef1f5;font-family:Arial,Helvetica,sans-serif;color:#1f2d5c;">
  <tr>
    <td align="center" style="padding:32px 12px;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:620px;background:#ffffff;border-radius:6px;overflow:hidden;border:1px solid #e1e5ec;box-shadow:0 8px 24px rgba(31,45,92,0.08);">
        <tr>
          <td style="height:7px;background:#ffc400;font-size:0;line-height:0;">&nbsp;</td>
        </tr>
        <tr>
          <td align="center" style="padding:34px 34px 22px;background:#ffffff;">
            <img src="${url.resourcesUrl}/img/logo_poma.png" alt="POMA" width="260" style="display:block;max-width:260px;width:100%;height:auto;border:0;outline:none;text-decoration:none;">
          </td>
        </tr>
        <tr>
          <td style="padding:0 38px 34px;">
            <h1 style="margin:0 0 18px;font-size:24px;line-height:1.25;font-weight:800;color:#1f2d5c;">${msg("resetTitle")}</h1>
            <p style="margin:0 0 14px;font-size:14px;line-height:1.6;color:#26345f;">${msg("emailGreeting")}</p>
            <p style="margin:0 0 14px;font-size:14px;line-height:1.6;color:#26345f;">${msg("resetIntro")} <strong>${realmName}</strong>.</p>
            <p style="margin:0 0 24px;font-size:14px;line-height:1.6;color:#26345f;">${msg("resetHelp")}</p>
            <table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 0 24px;">
              <tr>
                <td bgcolor="#ffc400" style="border-radius:4px;">
                  <a href="${link}" style="display:inline-block;padding:13px 22px;background:#ffc400;color:#ffffff;font-size:13px;line-height:1;font-weight:800;text-transform:uppercase;letter-spacing:.06em;text-decoration:none;border-radius:4px;">${msg("resetButton")}</a>
                </td>
              </tr>
            </table>
            <p style="margin:0 0 14px;font-size:13px;line-height:1.55;color:#4f5872;">${msg("resetExpiration")} <strong>${linkExpiration}</strong> ${msg("minutes")}.</p>
            <p style="margin:0 0 22px;font-size:13px;line-height:1.55;color:#4f5872;">${msg("resetIgnore")}</p>
            <div style="margin:0;padding:16px;background:#f5f7fb;border:1px solid #e3e8f0;border-radius:6px;">
              <p style="margin:0 0 8px;font-size:12px;line-height:1.45;color:#5c647a;">${msg("resetFallback")}</p>
              <p style="margin:0;font-size:12px;line-height:1.55;word-break:break-all;color:#1f2d5c;">${link}</p>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding:22px 38px;background:#1f2d5c;color:#ffffff;text-align:center;">
            <p style="margin:0 0 6px;font-size:14px;font-weight:800;line-height:1.4;color:#ffffff;">${msg("companyName")}</p>
            <p style="margin:0;font-size:12px;line-height:1.5;color:#d9deec;">${msg("resetFooter")}</p>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
</@layout.emailLayout>
