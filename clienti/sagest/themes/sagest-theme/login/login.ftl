<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>
    <#if section = "header">
        <span class="sagest-sr-only">${msg("loginAccountTitle")}</span>
    <#elseif section = "form">
        <div id="kc-form">
            <div id="kc-form-wrapper">
                <#if realm.password>
                    <form id="kc-form-login" action="${url.loginAction}" method="post">
                        <#if !usernameHidden??>
                            <div class="sagest-field sagest-username">
                                <label class="sagest-sr-only" for="username"><#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if></label>
                                <input id="username" name="username" value="${(login.username!'')}" type="text" autofocus autocomplete="username" dir="ltr"
                                       placeholder="<#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if>"
                                       aria-invalid="${messagesPerField.existsError('username','password')?c}" <#if messagesPerField.existsError('username','password')>aria-describedby="input-error"</#if>/>
                                <svg class="sagest-user-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true">
                                    <circle cx="12" cy="7" r="3"/><path d="M5 20v-2a7 7 0 0 1 14 0v2Z"/>
                                </svg>
                            </div>
                        </#if>
                        <div class="sagest-field sagest-password">
                            <label class="sagest-sr-only" for="password">${msg("password")}</label>
                            <input id="password" name="password" type="password" autocomplete="current-password" placeholder="${msg('password')}"
                                   aria-invalid="${messagesPerField.existsError('username','password')?c}" <#if messagesPerField.existsError('username','password')>aria-describedby="input-error"</#if>/>
                            <button class="sagest-password-toggle" type="button" aria-label="${msg('showPassword')}" aria-controls="password" aria-pressed="false"
                                    data-label-show="${msg('showPassword')}" data-label-hide="${msg('hidePassword')}" hidden>
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true">
                                    <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z"/><circle cx="12" cy="12" r="3"/>
                                    <path class="sagest-eye-slash" d="m3 21 18-18"/>
                                </svg>
                            </button>
                        </div>
                        <#if messagesPerField.existsError('username','password')>
                            <span id="input-error" class="sagest-field-error" aria-live="polite">${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}</span>
                        </#if>
                        <#if realm.rememberMe && !usernameHidden??>
                            <div id="kc-form-options" class="sagest-remember">
                                <label for="rememberMe"><input id="rememberMe" name="rememberMe" type="checkbox" <#if login.rememberMe??>checked</#if>/> ${msg("rememberMe")}</label>
                            </div>
                        </#if>
                        <div id="kc-form-buttons">
                            <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                            <input name="login" id="kc-login" type="submit" value="${msg('doLogIn')}"/>
                        </div>
                        <#if realm.resetPasswordAllowed>
                            <div class="sagest-forgot"><a href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a></div>
                        </#if>
                    </form>
                </#if>
            </div>
        </div>
        <#if social?? && social.providers?has_content>
            <div id="kc-social-providers">
                <ul>
                    <#list social.providers as p>
                        <li>
                            <a id="social-${p.alias}" href="${p.loginUrl}">
                                <#if p.providerId == "google">
                                    <img src="${url.resourcesPath}/img/google.svg" width="16" height="16" alt=""/>
                                <#elseif p.iconClasses?has_content>
                                    <i class="${p.iconClasses}" aria-hidden="true"></i>
                                </#if>
                                <span>${msg("sagestLoginWith", p.displayName)}</span>
                            </a>
                        </li>
                    </#list>
                </ul>
            </div>
        </#if>
        <script src="${url.resourcesPath}/js/login.js" defer></script>
    <#elseif section = "info">
        <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
            <div id="kc-registration-container">
                <div id="kc-registration">${msg("noAccount")} <a href="${url.registrationUrl}">${msg("doRegister")}</a></div>
            </div>
        </#if>
    </#if>
</@layout.registrationLayout>
