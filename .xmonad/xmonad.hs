-- Import statements
import System.IO
import System.Exit

import XMonad
import XMonad.Layout.SimpleFloat
import XMonad.Layout.NoBorders (noBorders)
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.ResizableTile

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Util.Run

import qualified XMonad.StackSet    as W
import qualified Data.Map           as M

myXMonadBar = "dzen2 -x '0' -y '0' -h '24' -w '960' -ta 'l' -fg '#FFFFFF' -bg '#1B1D1E'"
myStatusBar = "conky -c /home/wallace/.xmonad/.conky_dzen | dzen2 -x '960' -w '960' -h '24' -ta 'r' -bg '#1B1D1E' -fg '#FFFFFF'"
myBitmapsDir = "/home/wallace/.xmonad/dzen2"


myLogHook :: Handle -> X ()
--myLogHook h = dynamicLogWithPP $ defaultPP {
--      ppCurrent           =   dzenColor "#ebac54" "#1B1D1E" . wrap "[" "]"
--    , ppVisible           =   dzenColor "white" "#1B1D1E" . pad
--    , ppHidden            =   dzenColor "white" "#1B1D1E" . pad
--    , ppHiddenNoWindows   =   dzenColor "#7b7b7b" "#1B1D1E" . pad
--    , ppUrgent            =   dzenColor "#ff0000" "#1B1D1E" . pad
--    , ppWsSep             =   ""
--    , ppSep               =   " | "
--    , ppLayout            =   dzenColor "#ebac54" "#1B1D1E" .
--       (\x -> case x of
--         "ResizableTall"             ->      "^i(" ++ myBitmapsDir ++ "/tall.xbm)"
--         "Mirror ResizableTall"      ->      "^i(" ++ myBitmapsDir ++ "/mtall.xbm)"
--         "Full"                      ->      "^i(" ++ myBitmapsDir ++ "/full.xbm)"
--         "Simple Float"              ->      "~"
--         _                           ->      x
--        )
--    , ppTitle             =   (" " ++) . dzenColor "white" "#1B1D1E" . dzenEscape
--    , ppOutput            =   hPutStrLn h
--}
myLogHook h = dynamicLogWithPP $ defaultPP {
      ppCurrent           =   xmobarColor "#ebac54" "#1B1D1E" . wrap "[" "]"
    , ppVisible           =   xmobarColor "white" "#1B1D1E" . pad
    , ppHidden            =   xmobarColor "white" "#1B1D1E" . pad
    , ppHiddenNoWindows   =   xmobarColor "#7b7b7b" "#1B1D1E" . pad
    , ppUrgent            =   xmobarColor "#ff0000" "#1B1D1E" . pad
    , ppWsSep             =   ""
    , ppSep               =   " | "
    , ppLayout            =   xmobarColor "#ebac54" "#1B1D1E" .
        (\x -> case x of
         "ResizableTall"             ->      "Tall"
         "Mirror ResizableTall"      ->      "Mirror"
         "Full"                      ->      "Full"
         "Simple Float"              ->      "~"
         _                           ->      x
        )
    , ppTitle             =   (" " ++) . xmobarColor "white" "#1B1D1E" . shorten 80 -- . dzenEscape
    , ppOutput            =   hPutStrLn h
}

-- Define terminal
myTerminal = "urxvt"

-- Define the names of all workspaces
myWorkspaces = ["1", "2", "3", "4"]

-- Define the layouts
myDefaultLayouts = tiled ||| Mirror tiled ||| simpleFloat ||| noBorders Full
    where
        -- default tiling algorithm partitions the screen into two panes
        tiled = ResizableTall 1 (2/100) (1/2) [] --nmaster delta ratio --Tall nmaster delta ratio

        -- default number of windows in the master pane
        nmaster = 1

        -- default proportion of screen occupied by master pane
        ratio = 1/2

        -- percent of screen to increment by when resizing panes
        delta = 1/100

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "exe=`dmenu_path | dmenu -b -nb '#333333' -nf '#ffffff' -sb '#ebac54' -sf '#000000'` && eval \"exec $exe\"")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

    -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Shorten the tile
    , ((modm,               xK_z     ), sendMessage MirrorShrink)

    -- Lengthen the tile
    , ((modm,               xK_a     ), sendMessage MirrorExpand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
    | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
    , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
    | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
    , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


-- Run XMonad with this configuration
main = do
xmproc <- spawnPipe "xmobar"
--dzenLeftBar <- spawnPipe myXMonadBar
--dzenRightBar <- spawnPipe myStatusBar
xmonad $ withUrgencyHookC dzenUrgencyHook { args = ["-bg", "red", "fg", "black", "-xs", "1", "-y", "25"] } urgencyConfig { remindWhen = Every 15 } $ defaultConfig {
--xmonad $ defaultConfig {
    terminal = myTerminal
    , workspaces = myWorkspaces
    , layoutHook = avoidStruts $ myDefaultLayouts
    -- , logHook = dynamicLogWithPP $ xmobarPP { 
    --        ppOutput = hPutStrLn xmproc 
    --        , ppTitle = xmobarColor "green" "" . shorten 50
    --    }
    , logHook = myLogHook xmproc -- >> fadeInactiveLogHook 0xdddddddd
    --, logHook = myLogHook dzenLeftBar >> fadeInactiveLogHook 0xdddddddd
    , manageHook = manageDocks <+> manageHook defaultConfig
    , keys = myKeys
}

