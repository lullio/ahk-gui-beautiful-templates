; #Persistent
; #SingleInstance Force
; SetWorkingDir %A_ScriptDir%
#Include, <Default_Settings>

Menu, Tray, Icon, Shell32.dll, 174

Window := {Width: 590, Height: 390, Title: "Menu Interface"}  ; Version: "0.2"
Navigation := {Label: ["General", "Advanced", "Language", "Theme", "---", "Help", "About"]}

/*
   VARIÁVEIS INI (ARQUIVO DE CONFIGURAÇÃO PARA SALVAR DADOS) 
*/
if((A_PtrSize=8&&A_IsCompiled="")||!A_IsUnicode){ ;32 bit=4  ;64 bit=8
   SplitPath,A_AhkPath,,dir
   if(!FileExist(correct:=dir "\AutoHotkeyU32.exe")){
      MsgBox error
      ExitApp
   }
   Run,"%correct%" "%A_ScriptName%",%A_ScriptDir%
   ExitApp
}

if !InStr(A_OSVersion, "10.")
   appdata := A_ScriptDir
else
   appdata := A_AppData "\" regexreplace(A_ScriptName, "\.\w+"), isWin10 := true
iniPath = %appdata%\settings.ini
; se o arquivo não existir, criar ele.
If(!FileExist(iniPath))
{
      FileCreateDir, %appdata% ; criar a pasta
      FileAppend, "" ,iniPath ; criar o arquivo caso ñ exista
}

/*
	CRIAR A MENU BAR
*/
Menu, FileMenu, Add, &Abrir o GTM (Felipe)`tCtrl+O, MenuAbrirLink
Menu, FileMenu, Add, &Abrir o GTM (Propz)`tCtrl+Q, MenuAbrirLink
Menu, FileMenu, Add ; with no more options, this is a seperator
; Menu, FileMenu, Add, &Abrir Banco de dados INBOX`tCtrl+I, MenuAbrirLink
Menu, FileMenu, Add, &Abrir a Pasta de Backup`tCtrl+Q, MenuAbrirLink
Menu, FileMenu, Add, &Abrir a Pasta de Contas`tCtrl+Q, MenuAbrirLink

Menu, EditMenu, Add, Conectar Conta Google`tCtrl+G, MenuEditarBase
Menu, EditMenu, Add, Definir Configurações Post Request`tCtrl+S, MenuEditarBase
Menu, EditMenu, Add, Definir Configurações Get Request`tCtrl+S, MenuEditarBase
Menu, EditMenu, Add, Abrir Arquivo de Configuração`tCtrl+S, MenuEditarBase
Menu, EditMenu, Add ; with no more options, this is a seperator
Menu, EditMenu, Add, &Reiniciar o App`tCtrl+R, MenuAcoesApp
Menu, EditMenu, Add, &Sair do App`tCtrl+Esc, MenuAcoesApp

Menu, HelpMenu, Add, &Como usar o Programa?, MenuAjudaNotify
Menu, HelpMenu, Add ; with no more options, this is a seperator
Menu, HelpMenu, Add, &Qual é a função do botão 'Enviar'?, MenuAjudaNotify
Menu, HelpMenu, Add, &Qual é a função do botão 'Pesquisar'?, MenuAjudaNotify
Menu, HelpMenu, Add, &Qual é a função do botão 'Atualizar'?, MenuAjudaNotify
Menu, HelpMenu, Add, &Qual é a função do menu 'Editar'?, MenuAjudaNotify
Menu, HelpMenu, Add, &Qual é a função do campo "Filtrar Lista" e "Filtrar Dados"?, MenuAjudaNotify
Menu, HelpMenu, Add ; with no more options, this is a seperator
Menu, HelpMenu, Add, &Sobre o programa (Github), MenuAbrirLink
Menu, HelpMenu, Add, &Desenvolvedor, MenuAbrirLink
Menu, HelpMenu, Add, &WhatsApp, MenuAbrirLink

; Attach the sub-menus that were created above.
Menu, MyMenuBar, Add, &Abrir, :FileMenu
Menu, MyMenuBar, Add, &Editar, :EditMenu
Menu, MyMenuBar, Add, &Ajuda, :HelpMenu
Gui, Menu, MyMenuBar ; Attach MyMenuBar to the GUI

/*
 CRIAR O LAYOUT DA GUI
*/

Gui +LastFound -Resize +HwndhGui
Gui Color, FFFFFF
Gui Add, Picture, x0 y0 w1699 h1 +0x4E +HWNDhDividerLine1  ; Dividing line From left to right [top menu bar]

Gui Add, Tab2, x-666 y10 w1699 h334 -Wrap +Theme Buttons vTabControl
Gui Tab

Gui Add, Picture, % "x" -9999 " y" -9999 " w" 96 " h" 32 " vpMenuHover +0x4E +HWNDhMenuHover" ; Menu Hover
Gui Add, Picture, % "x" 0 " y" 18 " w" 4 " h" 32 " vpMenuSelect +0x4E +HWNDhMenuSelect" ; Menu Select

Gui Add, Picture, x96 y0 w1 h1340 +0x4E +HWNDhDividerLine3  ; Divider Top to bottom
Gui Add, Progress, x0 y0 w96 h799 +0x4000000 +E0x4 Disabled BackgroundF7F7F7 ; Left side constant background color

; Font size and font boldness for the left Tab header
Gui Font, W600 Q5 c808080, Segoe UI
Loop % Navigation.Label.Length() {
	GuiControl,, TabControl, % Navigation.Label[A_Index] "|"
	If (Navigation.Label[A_Index] = "---")
		Continue

	Gui Add, Text, % "x" 0 " y" (32*A_Index)-24 " h" 32 " w" 96 " Center +0x200 BackgroundTrans gMenuClick vMenuItem" . A_Index, % Navigation.Label[A_Index]
}
Gui Font

; Bottom button and background
Global HtmlButton1, HtmlButton2, clientId, clientSecret, view_id, start_date, end_date

view_id := "358422628" ; Substitua pelo ID da sua vista (propriedade)
start_date := "2024-01-01"
end_date := "2024-03-30"

clientId := "469887641674-8ourejn84lk7pimu99mnurdsi1nb3n7e.apps.googleusercontent.com"
clientSecret := "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"
scope := "https://www.googleapis.com/auth/analytics.readonly"

; Escreve o valor no arquivo .ini
IniWrite, %clientId%, %iniPath%, APIAuthentication, clientID
IniWrite, %clientSecret%, %iniPath%, APIAuthentication, clientSecret
IniWrite, %scope%, %iniPath%, APIAuthentication, scope

NewButton1 := New HtmlButton("HtmlButton1", "OK", "Button1_", (Window.Width-176)-20, (Window.Height-24)-14)
NewButton2 := New HtmlButton("HtmlButton2", "Cancel", "Button1_", (Window.Width-80)-20, (Window.Height-24)-14)

; Gui Add, Button, % "x" (Window.Width-176)-20 " y" (Window.Height-24)-14 " w78 h26 vButtonOK", OK
; Gui Add, Button, % "x" (Window.Width-80)-20 " y" (Window.Height-24)-14 " w78 h26 vButtonCancel", Cancel

Gui Add, Picture, x96 y340 w1001 h1 +0x4E +HWNDhDividerLine4  ; Dividing line From left to right [Bottom]
Gui Add, Progress, x0 y340 w1502 h149 +0x4000000 +E0x4 Disabled BackgroundFBFBFB


; Font size of the top right Tab title
Gui Font, s15 Q5 c000000, Segoe UI
Gui Add, Text, % "x" 117 " y" 4 " w" (Window.Width-110)-16 " h32 +0x200 vPageTitle"
Gui Add, Picture, % "x" 110 " y" 38 " w" (Window.Width-110)-16 " h1 +0x4E +HWNDhDividerLine2"  ; Dividing Line
Gui Font

Gui Tab, 1
Gui Font, W560, Segoe UI
Gui Add, Text, Section x116 y50 BackgroundWhite, Select your primary button
Gui Font
Gui Add, DropDownList, xs+10 w80 vPrimaryButton Choose1, Left||Right
Gui Font, W560, Segoe UI
Gui Add, Text, xs yp+40, Cursor Speed
Gui Font
Gui Add, Slider, vMySlider NoTicks, 50
Gui Font, W560, Segoe UI
Gui Add, Text, yp+40 , Roll the mouse wheel to scrol
Gui Font
Gui Add, Radio, xs+10 yp+22 h14 Checked, Multiple lines at a time
Gui Add, Radio, xs+10 y+8 h14, On screen at a time
Gui Font, W560, Segoe UI
Gui Add, Checkbox, xs yp+36 h14, Mouse Button Tips
Gui Font

Gui Tab, 2
Gui Add, ListView, % "x" 116 " y" 50 " w" (Window.Width-110)-30, Col1|Col2
LV_Add("", "ListView", "Example"), LV_ModifyCol()

Gui Tab, 3
Gui Add, MonthCal, % "x" 116 " y" 50

Gui Tab, 4
Gui Add, DateTime, % "x" 116 " y" 50, LongDate

Gui Tab, 5  ; Skipped

Gui Tab, 6
Gui Add, GroupBox, % "x" 116 " y" 50 " w" (Window.Width-110)-30, GroupBox

Gui Tab, 7
Gui Add, TreeView, % "x" 116 " y" 50 " w220 h148"
P1 := TV_Add("First parent"), P1C1 := TV_Add("Parent 1's first child", P1)

Gui Show, % " w" Window.Width " h" Window.Height, % Window.Title




; response := GetUsers(accessToken)
; MsgBox % "Resposta da API:" . "`n" . response
; GoSub, ReadIniFile
; Exemplo de uso


SetPixelColor("E9E9E9", hMenuHover)
SetPixelColor("0078D7", hMenuSelect)
Loop 4
    SetPixelColor("D8D8D8", hDividerLine%A_Index%)
SelectMenu("MenuItem1")
OnMessage(0x200, "WM_MOUSEMOVE")

; VERIFICAR SE JÁ EXISTE UM CÓDIGO DE ACESSO, SE NÃO EXISTIR, VAI ABRIR O NAVEGADOR E SOLICITAR AUTORIZAÇÃO
GoSub, ReadIniFile
ValidateAndRenewToken(clientId, clientSecret, scope)

response := GetUsers(accessToken)
MsgBox % "Resposta da API:" . "`n" . response
Return



MenuClick:
	SelectMenu(A_GuiControl)
Return

GuiClose:
	ExitApp

; HtmlButton Event Handling
Button1_OnClick() {
	ExitApp
}

SelectMenu(Control) {
	Global
    Loop % Navigation.Label.Length()
        SetControlColor("808080", Navigation.Label[A_Index])  ; Color of the unchecked button on the left

	CurrentMenu := Control
	, SetControlColor("237FFF", Control)  ; Color of the selected button on the left
	GuiControl, Move, pMenuSelect, % "x" 0 " y" (32*SubStr(Control, 9, 2))-20 " w" 4 " h" 24
	GuiControl, Choose, TabControl, % SubStr(Control, 9, 2)
	GuiControl,, PageTitle, % Navigation.Label[SubStr(Control, 9, 2)]
}

WM_MOUSEMOVE(wParam, lParam, Msg, Hwnd) {
	Global hMenuSelect
    Static hover := {}

    if (wParam = "timer") {
        MouseGetPos,,,, hControl, 2
        if (hControl != hwnd) && (hControl != hMenuSelect) {
            SetTimer,, Delete
            GuiControl, Move, pMenuHover, % "x" -9999 " y" -9999
            OnMessage(0x200, "WM_MOUSEMOVE")
            , hover[hwnd] := False
        }
     } else {
        if (InStr(A_GuiControl, "MenuItem") = True) {
            GuiControl, Move, pMenuHover, % "x" 0 " y" (32*SubStr(A_GuiControl, 9, 2))-24
            GuiControl, MoveDraw, pMenuHover
            hover[hwnd] := True
            , OnMessage(0x200, "WM_MOUSEMOVE", 0)
            , timer := Func(A_ThisFunc).Bind("timer", "", "", hwnd)
            SetTimer % timer, 15
        } else if (InStr(A_GuiControl, "MenuItem") = False)
            GuiControl, Move, pMenuHover, % "x" -9999 " y" -9999
    }
}

SetControlColor(Color, Control) {
	GuiControl, % "+c" Color, % Control

	; Required due to redrawing issues with the Tab2 control
	GuiControlGet, ControlText,, % Control
	GuiControlGet, ControlHandle, Hwnd, % Control
	DllCall("SetWindowText", "Ptr", ControlHandle, "Str", ControlText)
    GuiControl, MoveDraw, % Control
}

SetPixelColor(Color, Handle) {
	VarSetCapacity(BMBITS, 4, 0), Numput("0x" . Color, &BMBITS, 0, "UInt")
	, hBM := DllCall("Gdi32.dll\CreateBitmap", "Int", 1, "Int", 1, "UInt", 1, "UInt", 24, "Ptr", 0)
	, hBM := DllCall("User32.dll\CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2008)
	, DllCall("Gdi32.dll\SetBitmapBits", "Ptr", hBM, "UInt", 3, "Ptr", &BMBITS)
	return DllCall("User32.dll\SendMessage", "Ptr", Handle, "UInt", 0x172, "Ptr", 0, "Ptr", hBM)
}

; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=3851&start=360#p458266
; Replace the standard button with a web button style, compatible to XP system. If Gui turns on -DPIScale, you need to set the last parameter "DPIScale" of HtmlButton to non-0 to fix the match.
Class HtmlButton
{
	__New(ButtonGlobalVar, ButtonName, gLabelFunc, OptionsOrX:="", y:="", w:=78 , h:=26, GuiLabel:="", TextColor:="001C30", DPIScale:=False) {
		Static Count:=0
        f := A_Temp "\" A_TickCount "-tmp" ++Count ".DELETEME.html"

		Html_Str =
		(
			<!DOCTYPE html><html><head>
			<meta http-equiv="X-UA-Compatible" content="IE=edge">
			<style>body {overflow-x:hidden;overflow-y:hidden;}
				button { color: #%TextColor%;
					background-color: #F4F4F4;
					border-radius:2px;
					border: 1px solid #A7A7A7;
					cursor: pointer; }
				button:hover {background-color: #BEE7FD;}
			</style></head><body>
			<button id="MyButton%Count%" style="position:absolute;left:0px;top:0px;width:%w%px;height:%h%px;font-size:12px;font-family:'Microsoft YaHei UI';">%ButtonName%</button></body></html>
		)
        if (OptionsOrX!="")
            if OptionsOrX is Number
                x := "x" OptionsOrX
             else
                Options := " " OptionsOrX
        (y != "" && y := " y" y)
		Gui, %GuiLabel%Add, ActiveX, %  x . y . " w" w " h" h " v" ButtonGlobalVar . Options, Shell.Explorer
		FileAppend, % Html_Str, % f
		%ButtonGlobalVar%.Navigate("file://" . f)
        , this.Html_Str := Html_Str
        , this.ButtonName := ButtonName
        , this.gLabelFunc := gLabelFunc
        , this.Count := Count 
		, %ButtonGlobalVar%.silent := True
        , this.ConnectEvents(ButtonGlobalVar, f)
        if !DPIScale
            %ButtonGlobalVar%.ExecWB(63, 1, Round((A_ScreenDPI/96*100)*A_ScreenDPI/96) ) ; Fix ActiveX control DPI scaling
	}

    Text(ButtonGlobalVar, ButtonText) {
        Html_Str := StrReplace(this.Html_Str, ">" this.ButtonName "</bu", ">" ButtonText "</bu")
        FileAppend, % Html_Str, % f := A_Temp "\" A_TickCount "-tmp.DELETEME.html"
		%ButtonGlobalVar%.Navigate("file://" . f)
        , this.ConnectEvents(ButtonGlobalVar, f)
    }

    ConnectEvents(ButtonGlobalVar, f) {
		While %ButtonGlobalVar%.readystate != 4 or %ButtonGlobalVar%.busy
			Sleep 5
        this.MyButton := %ButtonGlobalVar%.document.getElementById("MyButton" this.Count)
		, ComObjConnect(this.MyButton, this.gLabelFunc)
		FileDelete, % f
    }
}




#Include src\connection\oauth-connection.ahk
#Include src\data-api-beta\get-requests.ahk


/*
      * LABELS DO MENU BAR
   */
   ; MENU ABRIR
   MenuAbrirLink:
      Gui Submit, NoHide
      ; if(A_UserName == "Felipe" || A_UserName == "estudos" || A_UserName == "Estudos")
      ; {
      ;    user := A_UserName
      ;    pass := "xrlo1010"
      ; }
      ; Else
      ; {
      ;    user := "felipe.lullio@hotmail.com"
      ;    pass := "XrLO1000@1010"
      ; }
      ; RunAs, %user%, %pass%
      If(InStr(A_ThisMenuItem, "Abrir o GTM (Felipe)"))
      {
         Run, "C:\Program Files\Google\Chrome\Application\chrome.exe" --profile-directory="Default" "https://tagmanager.google.com/#/home"
         ; Run, C:\Users\felipe\AppData\Local\Programs\Notion\Notion.exe
         ; Run %ComSpec% /c C:\Users\felipe\AppData\Local\Programs\Notion\Notion.exe "notion://www.notion.so/%NotionDatabaseLink%", , Hide
      }
      Else If(InStr(A_ThisMenuItem, "Abrir o GTM (Propz)"))
         Run, "C:\Program Files\Google\Chrome\Application\chrome.exe" --profile-directory="Profile 6" "https://tagmanager.google.com/#/home"
      Else If(InStr(A_ThisMenuItem, "Abrir a Pasta de Backup"))
         Run, %A_ScriptDir%/Contas-GTM
      Else If(InStr(A_ThisMenuItem, "Abrir a Pasta de Contas"))
         Run, %A_ScriptDir%/Contas-GTM
      Else If(InStr(A_ThisMenuItem, "WhatsApp"))
         Run, https://wa.me/5511991486309
      Else If(InStr(A_ThisMenuItem, "Desenvolvedor"))
         Run, https://www.lullio.com.br
   return

   ; MENU EDITAR - REINICIAR E FECHAR APP
   MenuAcoesApp:
      If(InStr(A_ThisMenuItem, "Sair"))
         ExitApp
      Else If(InStr(A_ThisMenuItem, "Reiniciar"))
         Reload
   return

   ; MENU EDITAR - CONFIGURAÇÕES DAS REQUISIÇÕES E AUTENTICAÇÃO API
   MenuEditarBase:
   ; msgbox % A_ThisMenuItem
      If(InStr(A_ThisMenuItem, "Definir Configurações Post Request"))
      {
         ; MsgBox, Open Menu was clicked
         Gui, ConfigFile:New, +AlwaysOnTop -Resize -MinimizeBox -MaximizeBox, Configurações da API
         Gui, ConfigFile:Add, Text,cRed, CUIDADO: Altere somente se souber o que está fazendo

         /*
         * COLUNA 1 - linha inteira
         */
         Gui, ConfigFile:Font, S9
         Gui, ConfigFile:Add, Text, center section h20, Client ID:
         Gui, ConfigFile:Add, Text, center, Client Secret:
         Gui, ConfigFile:Add, Text,center, Scope:
         Gui, ConfigFile:Add, Text,center, Código de Autorização:
         Gui, ConfigFile:Add, Text,center, Token de Acesso:
         Gui, ConfigFile:Add, Text,center, Token de Renovação:
         Gui, ConfigFile:Add, Text,center, Código Verificador(random):

         Gui, ConfigFile:Add, Edit, Password w350 ys x+30 vClientID
         Gui, ConfigFile:Add, Edit, Password w350 vClientSecret
         Gui ,ConfigFile:Add, ComboBox, w350 center vScope hwndScopeID, https://www.googleapis.com/auth/tagmanager.delete.containers https://www.googleapis.com/auth/tagmanager.edit.containers https://www.googleapis.com/auth/tagmanager.edit.containerversions https://www.googleapis.com/auth/tagmanager.manage.accounts https://www.googleapis.com/auth/tagmanager.manage.users https://www.googleapis.com/auth/tagmanager.publish 	||https://www.googleapis.com/auth/tagmanager.edit.containers|https://www.googleapis.com/auth/tagmanager.readonly|https://www.googleapis.com/auth/tagmanager.delete.containers|https://www.googleapis.com/auth/tagmanager.edit.containerversions|https://www.googleapis.com/auth/tagmanager.publish|https://www.googleapis.com/auth/tagmanager.manage.users|https://www.googleapis.com/auth/tagmanager.manage.accounts
         Gui, ConfigFile:Add, Edit, Password w350 vAuthorizedCode
         Gui, ConfigFile:Add, Edit, Password w350 vAccessToken
         Gui, ConfigFile:Add, Edit, Password w350 vRefreshToken
         Gui, ConfigFile:Add, Edit, w350 vCodigoVerificador

         gui, ConfigFile:font, S11 ;Change font size to 12
         gui, ConfigFile:Add, Button, center y+15 w90 gSaveToIniFile, &Salvar
         GoSub, ReadIniFile
         Gui, ConfigFile:Show, xCenter yCenter
      }Else If(InStr(A_ThisMenuItem, "Definir Configurações Get Request"))
      {
         ;   GoSub, ConnectToGTM
      }
      Else If(InStr(A_ThisMenuItem, "Conectar Conta Google"))
      {
         accessToken := GetAccessToken(clientId, clientSecret, scope)
         GoSub, ReadIniFile
         ValidateAndRenewToken(clientId, clientSecret)
      }
      Else If(InStr(A_ThisMenuItem, "Abrir Arquivo de Configura"))
      {
         ; MSGBOX HI
         Run % appdata
         Run % iniPath
      }
      
   Return

   ; MENU AJUDA
   MenuAjudaNotify:
      If(InStr(A_ThisMenuItem, "filtrar dados"))
         ; msgbox SUCESSO com SOM e ICONE alwaysontop
         MsgBox, 4160 , INFORMAÇÃO!, O campo "Filtrar Dados" destina-se a filtrar os dados da consulta ao banco de dados. `n`nEsse filtro tem a finalidade de excluir tarefas que foram arquivadas.`n`nObs: Existem duas checkboxes`, uma na tela principal e outra na tela de configurações do get request`, as duas são verificadas., 900
      Else If(InStr(A_ThisMenuItem, "como usar o programa"))
         ; msgbox SUCESSO com SOM e ICONE alwaysontop
         MsgBox, 4160 , INFORMAÇÃO!, 1. Para abrir uma tarefa no Notion`, clique com o botão esquerdo do mouse em qualquer item da Lista.`n`n2. Para arquivar ou desarquivar uma tarefa`, clique com o botão direito do mouse em qualquer item da Lista., 900
      Else If(InStr(A_ThisMenuItem, "Qual é a função do botão 'Enviar'"))
         ; msgbox SUCESSO com SOM e ICONE alwaysontop
         MsgBox, 4160 , INFORMAÇÃO!, O botão 'Enviar' tem a finalidade de cadastrar uma tarefa no banco de dados do Notion.`n`nVocê pode configurar e modificar qual banco de dados deseja utilizar nas opções do menu 'Editar' (CTRL+E)., 900
      Else If(InStr(A_ThisMenuItem, "Qual é a função do botão 'Pesquisar'"))
         ; msgbox SUCESSO com SOM e ICONE alwaysontop
         MsgBox, 4160 , INFORMAÇÃO!, O botão "Pesquisar" tem a finalidade de buscar uma tarefa na lista de tarefas exibida acima.`n`n O campo de pesquisa permite o uso de expressões regulares (regex) e`, por padrão`, a pesquisa não diferencia maiúsculas de minúsculas (não é "casesensitive").`n`nObservação:Você pode realizar uma pesquisa clicando no botão 'Pesquisar' ou pressionando a tecla 'Enter' no teclado., 900
      Else If(InStr(A_ThisMenuItem, "Qual é a função do botão 'Atualizar'"))
         ; msgbox SUCESSO com SOM e ICONE alwaysontop
         MsgBox, 4160 , INFORMAÇÃO!, O botão 'Atualizar' tem a função de enviar uma nova requisição HTTP à API do Notion e`, assim`, recarregar os dados na lista., 900
      Else If(InStr(A_ThisMenuItem, "Qual é a função do menu 'Editar'"))
         ; msgbox SUCESSO com SOM e ICONE alwaysontop
         MsgBox, 4160 , INFORMAÇÃO!, Dentro do menu 'Editar'`, você encontra a opção para definir e editar as configurações das requisições HTTP GET e POST.`n`nObservação: faça alterações apenas se estiver familiarizado com o processo`, pois trata-se de uma configuração ""avançada"""., 900
   Return










