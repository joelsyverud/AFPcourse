module NotAFunctor where
-- Not a functor
type NotAFunctor = Equal
newtype Equal a = Equal {runEqual :: a -> a -> Bool}

fmapEqual :: (a -> b) -> Equal a -> Equal b
fmapEqual _f (Equal _op) = Equal $ \_b1 _b2 -> error "Hopeless!"

cofmapEqual :: (b -> a) -> (Equal a -> Equal b)
cofmapEqual finv (Equal op) = Equal (\b1 b2 -> op (finv b1) (finv b2) )
  -- op      :: a -> a -> Bool
  -- a1, a2  :: a
  -- f       :: a -> b  -- does not work
  -- finv    :: b -> a                         

{-
fmap   :: Functor f   => (a -> b) -> (f a -> f b)
cofmap :: Cofunctor f => (b -> a) -> (f a -> f b)
-}

-- Good exercise:
--   work out some examples "in between" Functor, Applicative and Monad
-- http://stackoverflow.com/questions/7220436/good-examples-of-not-a-functor-functor-applicative-monad

-- Functor, but not Applicative

{- Either a -}

-- Applicative, but not Monad

{- ZipList
pure x                    = ZipList (repeat x)
ZipList fs <*> ZipList xs = ZipList (zipWith id fs xs)
-}

-- Monad
