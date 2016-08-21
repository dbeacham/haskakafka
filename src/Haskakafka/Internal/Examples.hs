{-# LANGUAGE ScopedTypeVariables #-}
module Haskakafka.Internal.Examples where

import Control.Monad (forM_)
import Foreign (peek)
import Foreign.Ptr (nullPtr, Ptr)
import Foreign.ForeignPtr (mallocForeignPtr, withForeignPtr)
import Foreign.Marshal.Array (peekArray)
import Foreign.C.String
import Haskakafka.Internal.Errors

-- get and print error codes
getErrors :: IO ()
getErrors = do
  _ed'' <- mallocForeignPtr
  _cs'  <- mallocForeignPtr
  withForeignPtr _ed'' $ \ed'' -> do
    withForeignPtr _cs' $ \cs' -> do
      rdKafkaGetErrDescs ed'' cs'
      sz <- fromIntegral <$> peek cs'
      ed' <- peek ed''
      ed <- peekArray sz ed'
      forM_ ed $ \(RdKafkaErrDesc cd cnm cds) -> do
        nm <- ifNullElse (return "") peekCString cnm
        ds <- ifNullElse (return "") peekCString cds
        putStrLn (show (fromEnum cd) ++ ": " ++ show cd)
        putStrLn (" " ++ nm)
        putStrLn (" " ++ ds)
        putStrLn ""

ifNullElse :: b -> (Ptr a -> b) -> Ptr a -> b
ifNullElse z f x | x == nullPtr = z
               | otherwise    = f x
