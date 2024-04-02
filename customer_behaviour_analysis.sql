use dannys_diner;

#Q1. What is the total amount each customer spent at the restaurant?
-- SELECT s.customer_id,SUM(m.price) as "total spent"
-- from sales s
-- join menu m 
-- on s.product_id =m.product_id
-- GROUP BY  s.customer_id;

# Q2. How many days has each customer visited the restaurant?
-- select customer_id , count(distinct order_date) as  "days visited" from sales
-- group by customer_id
 
 #Q3. What was the first item from the menu purchased by each customer?
--  with customer_first_purchase as (
--  select s.customer_id,MIN(s.order_date) as first_purchase_date
--  from sales s
--  group by s.customer_id
--  )
--  select cfp.customer_id , cfp.first_purchase_date,m.product_name
--  from customer_first_purchase as cfp
--  join sales s 
--  on s.customer_id=cfp.customer_id and cfp.first_purchase_date=s.order_date
--  join menu m on m.product_id=s.product_id
 
#Q.4 What is the most purchased item on the menu and how many times was it purchased by all customers?
-- select m.product_name,count(*) as total_purchased
-- from sales s
-- join menu m 
-- on s.product_id = m.product_id
-- group by m.product_name
-- order by total_purchased desc limit 1

 #Q5.Which item was the most popular for each customer?   #DOUBT
-- with customer_popularity as (
-- 	select s.customer_id,m.product_name,count(*) as purchase_count,
-- 	dense_rank() over(partition by s.customer_id order by count(*) desc) as purchase_rank
-- 	from sales s
-- 	join menu m
-- 	on s.product_id=m.product_id
-- 	group by s.customer_id ,m.product_name
-- )
-- select cp.customer_id, cp.product_name ,cp.purchase_count
-- from customer_popularity cp
-- where purchase_rank=1

# Q6. Which item was purchased first by the customer after they became a member?
-- with first_purchase_after_membership as (
-- 	select s.customer_id , min(s.order_date) as first_purchase_date 
-- 	from sales s
-- 	join members mb 
-- 	on s.customer_id=mb.customer_id
-- 	where s.order_date>=mb.join_date
-- 	group by s.customer_id
-- )
-- select fpam.customer_id ,s.order_date,fpam.first_purchase_date , m.product_name
-- from first_purchase_after_membership fpam
-- join sales s
-- on s.customer_id=fpam.customer_id
-- and fpam.first_purchase_date = s.order_date
-- join menu m
-- on s.product_id = m.product_id;

#Q7.Which item was purchased just before the customer became a member?     #doubt
-- with last_purchase_before_membership as(
-- 	select s.customer_id,max(s.order_date) as last_purchase_date
-- 	from sales s
-- 	join members mb
-- 	on s.customer_id=mb.customer_id
-- 	where s.order_date<mb.join_date
-- 	group by s.customer_id
-- )
-- select lpbm.customer_id, m.product_name
-- from last_purchase_before_membership as lpbm
-- join sales s 
-- on lpbm.customer_id=s.customer_id 
-- and lpbm.last_purchase_date=s.order_date
-- join menu m 
-- on s.product_id=m.product_id;

#Q8. What is the total items and amount spent for each member before they became a member?
-- select s.customer_id,count(*) as "total items" ,sum(m.price) as "total spent"
-- from sales s
-- join menu m
-- on s.product_id=m.product_id
-- join members mb
-- on s.customer_id=mb.customer_id
-- where s.order_date<mb.join_date
-- group by s.customer_id

#Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier – how many points would each customer have?
-- select s.customer_id , sum(
-- 	case 
-- 		when m.product_name='sushi' then m.price*20
--         else m.price*10 end) as total_point
-- from sales s
-- join menu m
-- on s.product_id =m.product_id
-- group by s.customer_id

#Q10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi. How many points do customer A and B have at the end of January?
-- select s.customer_id,sum(
-- 	case
--     when s.order_date between mb.join_date and DATE_ADD(mb.join_date,interval 7 day)
--     then m.price*20
--     when m.product_name='sushi' then m.price*20
--     else m.price*10 
--     end
-- ) as total_points
-- from sales s
-- join menu m 
-- on s.product_id=m.product_id
-- left join members mb 
-- on s.customer_id=mb.customer_id
-- where s.customer_id IN ('A','B') and s.order_date<='2021-01-31'
-- group by s.customer_id


#Q10. Recreating the table
-- select s.customer_id,s.order_date,m.product_name,m.price,
-- case when s.order_date>mb.join_date then 'Y'
-- else 'N' end as member
-- from sales s
-- join menu m on s.product_id=m.product_id
-- left join members mb on s.customer_id=mb.customer_id
-- order by s.customer_id,s.order_date

#Q11 In continuation to Q10, add ranking of members as well . For Non members-->Null
with customers_data as (
	select s.customer_id,s.order_date,m.product_name,m.price,
	case when s.order_date>mb.join_date then 'Y'
	else 'N' end as member
	from sales s
	join menu m on s.product_id=m.product_id
	left join members mb on s.customer_id=mb.customer_id
	order by s.customer_id,s.order_date
) 
select *,
case when member='N' then NULL
else rank() over(partition by customer_id,member order by order_date)
end as ranking
from customers_data
order by customer_id,order_date