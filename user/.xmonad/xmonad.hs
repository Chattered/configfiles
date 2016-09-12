module Main where

import XMonad
import XMonad.Util.Run
import XMonad.Util.EZConfig
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import System.Posix.Env

main = do
  h <- spawnPipe "xmobar"
  xmonad $ defaultConfig
        { logHook    = dynamicLogWithPP $ xmobarPP { ppOutput = hPutStrLn h }
        , layoutHook = avoidStruts $ layoutHook defaultConfig
        , manageHook = manageHook defaultConfig <+> manageDocks
        , modMask = mod4Mask
        , terminal = "xterm"
        } `additionalKeys`
       [ ((mod4Mask .|. shiftMask, xK_f),
          spawn "nix-shell -p firefox --run firefox")
       , ((mod4Mask .|. shiftMask, xK_m),
          spawn "nix-shell -A emacs --run 'emacsclient -c'")
       , ((mod4Mask              , xK_x), spawn "xlock -mode blank")
       ]
