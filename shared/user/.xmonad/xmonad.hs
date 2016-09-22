module Main where

import Alsa
import Control.Applicative
import Control.Monad
import Data.Ix
import System.Posix.Env (getEnv, setEnv)
import System.FilePath.Posix ((</>))
import System.Exit
import XMonad
import XMonad.Util.Run
import XMonad.Util.EZConfig
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog

onPlayback :: (Elem -> Alsa a) -> Alsa a
onPlayback f = do
  (p:_) <- elems
  f p

volumeInRange :: Elem -> Integer -> Alsa Bool
volumeInRange e v = inRange <$> volumeRange e <*> return v

volumeIncrement :: Elem -> Integer -> Alsa Integer
volumeIncrement e steps = do
  (min,max) <- volumeRange e
  return $ (max - min) `div` steps

upVolume :: Alsa ()
upVolume = onPlayback $ \p -> do
  inc   <- volumeIncrement p 20
  cv    <- volume p 0
  switchOn p 0 >> switchOn p 1
  b     <- volumeInRange p $ cv + inc
  when b (setVolume p 0 (cv + inc)
          >> setVolume p 1 (cv + inc))

downVolume :: Alsa ()
downVolume = onPlayback $ \p -> do
  inc   <- volumeIncrement p 20
  cv    <- volume p 0
  b     <- volumeInRange p $ cv - inc
  when b (setVolume p 0 (cv - inc) >> setVolume p 1 (cv - inc))

muteVolume :: Alsa ()
muteVolume = onPlayback $ \p -> do
  switchOff p 0 >> switchOff p 1

main = do
  Just home <- getEnv "HOME"
  setEnv "NIX_PATH" (home </> "unstable") False
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
       , ((mod4Mask .|. shiftMask, xK_g),
          spawn "nix-shell -p google-chrome --run google-chrome-stable")    
       , ((mod4Mask .|. shiftMask, xK_m),
          spawn "nix-shell -A emacs --run 'emacsclient -c'")
       , ((mod4Mask,               xK_u), liftIO . runAlsa $ upVolume)
       , ((mod4Mask,               xK_d), liftIO . runAlsa $ downVolume)
       , ((mod4Mask .|. shiftMask, xK_d), liftIO . runAlsa $ muteVolume)
       , ((mod4Mask              , xK_x), spawn "xlock -mode blank")
       ]
