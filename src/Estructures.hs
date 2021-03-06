{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE Strict, StrictData #-}

module Estructures where

import qualified Data.Map.Strict as Map
import Data.Time
import Data.Binary

{-# ANN module "HLint: ignore Use camelCase" #-} 


-- Keeps the answeris of each pupil in the form pupilid - answers
type IAMap = Map.Map Int [Answer]
iaMap::IAMap
iaMap = Map.empty


-- Map of integer - integer
type IIMap = Map.Map Int Int
iiMap::IIMap
iiMap = Map.empty


-- Map of integer - double
type IDMap = Map.Map Int Double
idMap::IDMap
idMap = Map.empty

-- Map of questionid - global
-- Global keeps track of invidual statistics for a question
type IADMap = Map.Map Int AnswerData
iadMap::IADMap
iadMap = Map.empty


-- Map from questionId to a Relation
type AllRelations = Map.Map Int Relations
newAllRelations::AllRelations
newAllRelations = Map.empty

-- A tag is connected to a question in a many-to-many-relation
-- A tags simpli tags questions

type Tags = Map.Map String [Int]
newTags::Tags
newTags = Map.empty :: Tags

-- Map of Courses

type TPMap = Map.Map Int Course
newCourseMap::TPMap
newCourseMap = Map.empty


-- Answers, containing all answers from the pupils
-- Every answer contains the max-score, it is for keeping the history of the answer

type Pupil = Int

data Answer = Answer {
   answer_questionId :: Int,
   answer_points :: Double
} deriving (Show, Eq)

instance Binary Answer where
   put Answer{..} = do put answer_questionId; put answer_points
   get = do answer_questionId <- get; answer_points <- get; return Answer{..}

data Answers = Answers Pupil [Answer] deriving (Eq)

instance Show Answers where
   show (Answers pupil answers) = "Pupil-id: " ++ show pupil ++ "\n" ++ concatMap (\a -> "  " ++ show a ++ "\n") answers 

instance Binary Answers where
    put (Answers pupil answers) = do put pupil; put answers;
    get = do pupil <- get;
             answers <- get;
             let res = Answers pupil answers
             return res


--- Answer relations
--- Each realation is between a question and all answers that can be connected to that question
--- The base for the connections are found in the answer datatype
--- So if one pupil has answers on question 2 and 4 we calculate the relations between these, based on their points
--- questionId is simpley the QuestionId in the to relation (related to this question)
--- points is the number of aggregated points that is scored in this relations
--- nums as the number of counted relations

data Relations = Relations {
   relation_questionId :: Int,
   relation_points :: IIMap,
   relation_nums :: IIMap
} deriving (Show, Eq)

instance Binary Relations where
   put Relations{..} = do put relation_questionId; put relation_points; put relation_nums;
   get = do relation_questionId <- get; relation_points <- get; relation_nums <- get; return Relations{..}

empty_relation::Int -> Relations
empty_relation qId = Relations qId iiMap iiMap

--- Answer global results
--- Keeps track of accumulated answers results
--- Each time we get an answer from at pupil we update this structure
--- points = number of points scored on the question
--- max = max number of point scored on the question
--- numb = number of pupils


data AnswerData = AnswerData {
   ad_points :: Double,
   ad_max :: Double,
   ad_nums :: Int,
   ad_pass_points :: Double,
   ad_failed :: Int
} deriving (Show, Eq)


instance Binary AnswerData where
   put AnswerData{..} = do put ad_points; put ad_max; put ad_nums; put ad_pass_points; put ad_failed;
   get = do ad_points <- get; ad_max <- get; ad_nums <- get; ad_pass_points <- get; ad_failed <- get; return AnswerData{..}


-- A snapshow of learning info on a given point in time

data Course = Course {
   course_all_relations :: AllRelations,
   course_answers :: IAMap,
   course_id :: Int,
   course_total_failed :: Int,
   course_total_passed :: Int
} deriving (Show, Eq)

empty_course ::  Root -> (Root, Course)
empty_course root =
   let courses = root_courses root
       tpId = case Map.lookupMax courses of
                 Just (oldId, _) -> oldId + 1
                 Nothing -> 1
       course = Course newAllRelations iaMap tpId 0 0
       newCourses = Map.insert tpId course courses
       newRoot = root { root_courses = newCourses }
   in (newRoot, course)

ccompare::Ord p => p -> p -> Ordering -> Ordering
ccompare v v' n = let res = compare v v' in if res /= EQ then res else n

-- instance Ord Course where
--   (Course year month week _ _ _) `compare` (Course year' month' week' _ _ _) =
--      ccompare year year' $ ccompare month month' $ ccompare week week' EQ


-- Score: how good a pupil has scored on a question

data PupilScore = PupilScore {
    ps_qid :: Int,
    ps_points :: Double,
    ps_max :: Double,
    ps_score :: Double
     } deriving (Show, Eq)

instance Ord PupilScore where
  (PupilScore _ _ _ score1) `compare` (PupilScore _ _ _ score2) =
    score1 `compare` score2

-- smoother

data SmootType = SmoothPercentage Double | SmoothAbsolute Double


-- root ---

data Root = Root {
  root_tags :: Tags,
  root_answerData :: IADMap,
  root_courses :: TPMap
} deriving (Show, Eq)

main2::IO()
main2 = do
   putStrLn "Life is short"
   c <- getCurrentTime
   let (y,m,d) = toGregorian $ utctDay c
   print (y,m,d)
