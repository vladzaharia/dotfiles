#Requires AutoHotkey v2.0

Path := "C:\Program Files\WezTerm\wezterm-gui.exe"
Criteria := Format("ahk_exe {}", Path)

LaunchWezTerm()
{
    if !WinExist(Criteria) ;
    {
        Run Path
        ActivateAndMoveWezTerm()
    }
    else ;
    {
        if WinActive(Criteria) ;
        {
            WinMoveBottom ;
            Send "!{Tab}"
        }
        else
            ActivateAndMoveWezTerm()
    }
}

ActivateAndMoveWezTerm()
{
    WinWait Criteria
    WinMoveTop ;
    WinActivate ;
    WinMove A_ScreenWidth/6, 0, 2*A_ScreenWidth/3, 2*A_ScreenHeight/3 ;
}

^`::LaunchWezTerm()