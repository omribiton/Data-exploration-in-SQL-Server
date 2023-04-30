


-- select club members details that : 1. Previously got a campaign thru personal media.
--									  2. Never opened a campaign that been sent to their personal media.
--									  3. Never been active in a campaign published on a social media.

select distinct c.memberCode, c.firstName + ' ' + c.lastName as fullName,
               DATEDIFF(day,c.joinDate,GETDATE()) seniority
from tblClubMember c inner join tblSentToMember stm on c.memberCode = stm.memberCode
where month(stm.sendDate) = MONTH(GETDATE()) 
      and c.memberCode not in (select memberCode
						       from tblSentToMember
							   where hasOpend = 1)
	or c.memberCode not in (select memberCode
						    from tblActiveInCampaign)



--		select campaigns details that published on social media and got over X likes, Y shares and Z comments. 
--	    (X, Y, Z are parameters obtained from the user)

declare @X smallint
set @X = 1000;
declare @Y smallint
set @Y = 200;
declare @Z smallint
set @Z = 500;
select c.campaignCode, c.CampaignName, c.beginDate, DATEDIFF(day, beginDate, endDate) as Duration, csm.mediaCode
from tblCampaign c inner join tblCampaignInSocialMedia csm on c.campaignCode =
	 csm.campaignCode
where @X < csm.noOfLikes and csm.NoOfShares > @Y and csm.noOfComments >@Z



-- Select the amount of money to each club member in any brand he purchased in the past year, 
--	the total spent on purchases at the brand store, average monthly spending and the number of different months in which the store was observed this year. 
--	This data should only be displayed for brand stores where the member have been seen more than 3 times in the past year at the brand store.

select c.memberCode , c.firstName + ' ' + c.lastName as fullName,
	   DATEDIFF(year, c.birthdate, GETDATE()) Age, b.* ,sum(m.totalMoney) totalCost, sum(m.totalMoney)/12
       avgSpent,count(m.mMonth) countMonth
from tblClubMember c inner join tblMeasuresFor m on c.memberCode = m.memberCode
	 inner join tblBrand b on m.brandCode = b.brandCode
where m.mYear = YEAR(GETDATE()) -2
group by c.memberCode , c.firstName , c.lastName, c.birthdate, b.brandCode ,b.brandName
having count(m.mMonth) > 3
order by fullName, c.memberCode, totalCost



-- Select club members details who are in at least one of the two following conditions:
-- Interested in all club brand stores.
-- There is an index for them in the current year in all the club brand stores.

select c.memberCode , c.firstName + ' ' + c.lastName as fullName
from tblIntrestedIn i inner join tblClubMember c on i.memberCode = c.memberCode
group by c.memberCode , c.firstName ,c.lastName
having count(distinct i.brandCode) = 10
union
select m.memberCode , c.firstName + ' ' + c.lastName as fullName
from tblMeasuresFor m inner join tblClubMember c on m.memberCode = c.memberCode
where m.mYear = GETDATE()
group by m.memberCode , c.firstName ,c.lastName
having count(distinct m.brandCode) = 10



-- Select details of "Strong" brands. A "Strong" brand is
-- A brand whose number of campaigns was the largest last year and the year before.
-- Without using - join !

select *
from tblBrand
where brandCode in (select brandCode
					from tblCampaignOfBrand
					where campaignCode in (select c.campaignCode
										   from tblCampaign c
										   where YEAR(c.beginDate) = YEAR(GETDATE())-1)
										   group by brandCode
										   having COUNT(brandCode)= (select top 1 COUNT(brandCode)
																	 from tblCampaignOfBrand
																	 where campaignCode in (select c.campaignCode
																							from tblCampaign c
																							where YEAR(c.beginDate) = YEAR(GETDATE())-1)
																							group by brandCode
																							order by COUNT(brandCode) desc )
intersect
select brandCode
from tblCampaignOfBrand
where campaignCode in (select c.campaignCode
					   from tblCampaign c
                       where YEAR(c.beginDate) = YEAR(GETDATE())-2)
					   group by brandCode
					   having COUNT(brandCode)= (select top 1 COUNT(brandCode)
												 from tblCampaignOfBrand
												 where campaignCode in (select c.campaignCode
																		from tblCampaign c
																		where YEAR(c.beginDate) = YEAR(GETDATE())-2)
																		group by brandCode
																		order by COUNT(brandCode) desc ))