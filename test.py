class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        all = {}
        for i in range(len(nums)):
            if target - nums[i] in all: 
                return list(all[target - nums[i]], i)
            all[nums[i]] = i