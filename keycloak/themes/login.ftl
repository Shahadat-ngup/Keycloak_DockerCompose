<#import "template.ftl" as layout>
<@layout.main>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <div style="width: 100%; min-height: 100vh; background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 50%, #dee2e6 100%); background-attachment: fixed; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif; margin: 0; padding: 0;">
        <!-- Header image only, no text -->
        <div class="mobile-header" style="width: 100%; min-height: 100px; background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%); display: flex; align-items: center; justify-content: flex-start; padding: 25px; margin: 0; box-shadow: 0 2px 20px rgba(0,0,0,0.08); position: relative; z-index: 10;">
            <img src="${url.resourcesPath}/img/header_left.jpg" alt="IPB Header" id="header-image"
                 style="height: 80px; width: auto; max-width: 280px; margin-right: 0; display: block !important; visibility: visible !important; opacity: 1 !important; object-fit: contain; image-rendering: auto; filter: drop-shadow(0 2px 8px rgba(0,0,0,0.1));">
        </div>
        <!-- Purple Accent Bar -->
        <div class="purple-accent-bar" style="width: 100%; height: 6px; background: linear-gradient(90deg, #6f42c1 0%, #5f2da8 50%, #6f42c1 100%); margin: 15px 0 25px 0; padding: 0; box-shadow: 0 2px 8px rgba(111, 66, 193, 0.3); position: relative; z-index: 9;"></div>
        <!-- Main Content Area -->
        <div class="main-content" style="width: 100%; padding: 50px 20px; display: flex; justify-content: center; align-items: flex-start; min-height: calc(100vh - 180px); margin-top: 25px;">
            <div class="login-container" style="width: 100%; max-width: 420px; background: linear-gradient(135deg, #ffffff 0%, #fafbfc 100%); border: 1px solid #e1e5e9; border-radius: 20px; padding: 40px; box-shadow: 0 10px 40px rgba(0,0,0,0.12), 0 4px 16px rgba(0,0,0,0.08); margin: 0 20px; position: relative; backdrop-filter: blur(10px); overflow: hidden;">
                <div style="position: relative; z-index: 1; display: flex; flex-direction: column; align-items: center;">
                    <#if realm.password>
                        <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post" style="width: 100%; display: flex; flex-direction: column; align-items: center;">
                            <div style="margin-bottom: 36px; width: 100%; display: flex; flex-direction: column; align-items: center;">
                                <label class="ultra-professional-label" style="font-size: 1.15rem; font-weight: 600; color: #6f42c1; margin-bottom: 12px; display: flex; flex-direction: column; align-items: center;">
                                    <span><i style="margin-right: 12px; color: #6f42c1; font-size: 2.2rem; vertical-align: middle;">👤</i> Código de Utilizador</span>
                                </label>
                                <input type="text" id="username" name="username" 
                                       value="${(login.username!'')}" 
                                       autofocus 
                                       autocomplete="off"
                                       aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                                       onkeypress="return handleEnter(this, event)" 
                                       class="ultra-professional-input"
                                       style="font-size: 1.15rem; padding: 12px 14px; border-radius: 10px; border: 2px solid #6f42c1; width: 100%; max-width: 240px; text-align: center;">
                                <#if messagesPerField.existsError('username','password')>
                                    <div class="ultra-professional-error" aria-live="polite" style="width: 100%; max-width: 320px; text-align: center;">
                                        <i style="margin-right: 6px;">⚠️</i> ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                                    </div>
                                </#if>
                            </div>
                            <div style="margin-bottom: 36px; width: 100%; display: flex; flex-direction: column; align-items: center;">
                                <label class="ultra-professional-label" style="font-size: 1.15rem; font-weight: 600; color: #6f42c1; margin-bottom: 12px; display: flex; flex-direction: column; align-items: center;">
                                    <span><i style="margin-right: 12px; color: #6f42c1; font-size: 2.2rem; vertical-align: middle;">🔒</i> Senha de Acesso</span>
                                </label>
                                <input type="password" id="password" name="password" 
                                       autocomplete="off"
                                       aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                                       class="ultra-professional-input"
                                       style="font-size: 1.15rem; padding: 12px 14px; border-radius: 10px; border: 2px solid #6f42c1; width: 100%; max-width: 240px; text-align: center;">
                            </div>
                            <div style="margin-bottom: 36px; width: 100%; display: flex; flex-direction: column; align-items: center;">
                                <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                                <input type="submit" value="Entrar" name="login" id="kc-login" class="ultra-professional-button"
                                    style="background: linear-gradient(135deg, #6f42c1 0%, #5f2da8 100%); font-size: 1.05rem; font-weight: 600; border-radius: 10px; padding: 10px 0; width: 100%; max-width: 180px; text-align: center; margin: 0 auto;">
                            </div>
                            <#if realm.rememberMe && !usernameEditDisabled??>
                            <div style="margin-bottom: 20px; text-align: center; width: 100%; display: flex; justify-content: center;">
                                <label style="font-size: 0.95rem; color: #6f42c1; display: flex; align-items: center; justify-content: center; cursor: pointer; font-weight: 500;">
                                    <#if login.rememberMe??>
                                        <input id="rememberMe" name="rememberMe" type="checkbox" checked style="margin-right: 10px; accent-color: #6f42c1; width: 18px; height: 18px;">
                                    <#else>
                                        <input id="rememberMe" name="rememberMe" type="checkbox" style="margin-right: 10px; accent-color: #6f42c1; width: 18px; height: 18px;">
                                    </#if>
                                    <i style="margin-right: 6px; font-size: 1.1rem;">💾</i> Lembrar-me neste dispositivo
                                </label>
                            </div>
                            </#if>
                        </form>
                    </#if>
                </div>
            </div>
        </div>
    </div>
    <script>
        // ... (your existing JS for styling, focus, etc. can go here) ...
    </script>
</@layout.main>