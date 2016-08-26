{-# LANGUAGE ScopedTypeVariables #-}
module Haskakafka.Internal.Examples where

import Control.Monad (forM_)
import Foreign (peek)
import Foreign.Ptr (nullPtr, Ptr)
import Foreign.ForeignPtr (ForeignPtr, mallocForeignPtr, withForeignPtr)
import Foreign.Marshal.Array (peekArray)
import Foreign.C.String

import Haskakafka.Internal.CTypes
import Haskakafka.Internal.Configuration
import Haskakafka.Internal.Kafka
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

-- setting up a producer / consumer
newRdKafkaT
  :: RdKafkaTypeT
  -> Ptr RdKafkaConfT
  -> Int
  -- ^ size of error buffer
  -> IO (Either String (ForeignPtr RdKafkaT))
newRdKafkaT kafkaType confPtr szErrBuf = do
  dupConfPtr <- maybeNull confPtr return rd_kafka_conf_dup
  rdKafkaNew kafkaType dupConfPtr szErrBuf

maybeNull
  :: Ptr a
  -> (Ptr a -> IO (Ptr b))
  -> (Ptr a -> IO (Ptr b))
  -> IO (Ptr b)
maybeNull ptr f g | ptr == nullPtr = f nullPtr
                  | otherwise      = g ptr
