<#import "template.ftl" as layout>
<@layout.emailLayout>
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:0;padding:0;background:#f4f7fb;font-family:Arial,Helvetica,sans-serif;color:#2f3442;">
  <tr>
    <td align="center" style="padding:32px 12px;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:620px;background:#ffffff;border-radius:16px;overflow:hidden;border:1px solid #e6eaf2;box-shadow:0 10px 30px rgba(47,52,66,0.10);">
        <tr>
          <td style="height:7px;background:#4547d9;font-size:0;line-height:0;">&nbsp;</td>
        </tr>
        <tr>
          <td align="center" style="padding:34px 34px 22px;background:#ffffff;">
            <img src="${url.resourcesUrl}/img/logo.png" alt="ICTGROUP" width="260" style="display:block;max-width:260px;width:100%;height:auto;border:0;outline:none;text-decoration:none;">
          </td>
        </tr>
        <tr>
          <td style="padding:0 38px 34px;">
            <h1 style="margin:0 0 18px;font-size:24px;line-height:1.25;font-weight:800;color:#2f3442;">${msg("verifyTitle")}</h1>
            <p style="margin:0 0 14px;font-size:14px;line-height:1.6;color:#3f4652;">${msg("emailGreeting")}</p>
            <p style="margin:0 0 24px;font-size:14px;line-height:1.6;color:#3f4652;">${msg("verifyIntro")}</p>
            <table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 0 24px;">
              <tr>
                <td bgcolor="#4547d9" style="border-radius:12px;">
                  <a href="${link}" style="display:inline-block;padding:13px 22px;background:#4547d9;color:#ffffff;font-size:13px;line-height:1;font-weight:800;text-transform:uppercase;letter-spacing:.06em;text-decoration:none;border-radius:12px;">${msg("verifyButton")}</a>
                </td>
              </tr>
            </table>
            <p style="margin:0 0 14px;font-size:13px;line-height:1.55;color:#6f7480;">${msg("resetExpiration")} <strong>${linkExpiration}</strong> ${msg("minutes")}.</p>
            <p style="margin:0 0 22px;font-size:13px;line-height:1.55;color:#6f7480;">${msg("verifyIgnore")}</p>
            <div style="margin:0;padding:16px;background:#f8fafc;border:1px solid #e6eaf2;border-radius:12px;">
              <p style="margin:0 0 8px;font-size:12px;line-height:1.45;color:#6f7480;">${msg("resetFallback")}</p>
              <p style="margin:0;font-size:12px;line-height:1.55;word-break:break-all;color:#4547d9;">${link}</p>
            </div>
          </td>
        </tr>

        <tr>
          <td style="padding:22px 38px;background:#2f3442;color:#ffffff;text-align:center;">
            <p style="margin:0 0 6px;font-size:14px;font-weight:800;line-height:1.4;color:#ffffff;">${msg("companyName")}</p>
            <p style="margin:0;font-size:12px;line-height:1.5;color:#dfe5ef;">${msg("resetFooter")}</p>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
</@layout.emailLayout>
