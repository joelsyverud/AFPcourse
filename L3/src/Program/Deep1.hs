{-# LANGUAGE GADTs #-}
{-|
  A simple embedded language for input/output. Deep embedding.
-}
module Program.Deep1 where
import Control.Applicative (Applicative(..))
import Control.Monad       (liftM, ap)

type Input   =  String
type Output  =  String

data Program a where
  Put    :: Char -> Program ()
  Get    :: Program (Maybe Char)
  Return :: a -> Program a
  Bind   :: Program a -> (a -> Program b) -> Program b

type IOSem a = Input  -> (a      , Input, Output)
-- | run function: translate syntax to semantics
run :: Program a -> IOSem a
run (Put c)    inp =     (()     ,inp   , c:"")
run (Get)      ""  =     (Nothing, ""   , ""  )
run (Get)      (c:cs) =  (Just c ,cs    , ""  )
run (Return x) inp =     (x      ,inp   , ""  )
run (Bind p g) inp =     (someb  ,someinp', someoutp ++ someoutp')
   where   (someb, someinp', someoutp') = run pb someinp
           pb = g somea
           (somea, someinp, someoutp) = run p inp 
-- p :: Program a
-- g :: a -> Program b
--  :: IOSem b
-- inp :: Input = String        

example1 :: Program ()
example1 = Put 'a'

example2 = Get >>= f
  where f Nothing  = example1
        f (Just c) = Put c >> Put c

instance Monad Program where
  return  =  Return
  (>>=)   =  Bind


--------
-- Preparing for the Functor-Applicative-Monad proposal:
--   https://www.haskell.org/haskellwiki/Functor-Applicative-Monad_Proposal

-- | The following instances are valid for _all_ monads:
instance Functor Program where
  fmap = liftM
  
instance Applicative Program where
  pure   = return
  (<*>)  = ap

{-

-- | The trivial deep embedding. We need to use a GADT to be allowed
--   the specific types on 'Get' and 'Put'.
data Program a where
  Put    :: Char -> Program ()
  Get    :: Program (Maybe Char)  -- (Nothing) signals "end of input"
  Return :: a -> Program a
  (:>>=) :: Program a -> (a -> Program b) -> Program b

type IOSem a = Input -> (a, Input, Output)
-- | run function: translate syntax to semantics
run :: Program a -> IOSem a
run (Put c)     i        =  ((),       i,   [c])
run Get         []       =  (Nothing,  [],  [])
run Get         (c : i)  =  (Just c,   i,   [])

run (Return x)  i        =  (x,        i,   [])
run (p :>>= f)  i        =  (y,        i2,  o1 ++ o2) 
  where  (x,  i1,  o1)   =  run p i
         (y,  i2,  o2)   =  run (f x) i1

instance Monad Program where
  return  =  Return
  (>>=)   =  (:>>=)
  -- fail has no natural definition for the (Program a) datatype

-- | Output a character.
putC :: Char -> Program ()
putC = Put

-- | Input a character.
getC :: Program (Maybe Char)
getC = Get
-}
