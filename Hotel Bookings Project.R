## Hotel Bookings Project ##

################################################### Data Import ###################################################

Hotel_Bookings <- read.csv(file = "C:\\Users\\barca\\Downloads\\SQL Projects\\hotel_booking.csv", header = TRUE)

## Using the read.csv() function I am able to select the file and then tell R that there is headers in my data set.

################################################### Exploration ###################################################
library(tidyverse)
library(dplyr)
## Getting to know the data
str(Hotel_Bookings)
glimpse(Hotel_Bookings)

# From these functions, I know that the data set contains 36 columns with 119390 rows. However, the data set contains 
# some personal information. Due to privacy concerns I will immediately remove all personal information
# before continuing exploration

## Removing personal information and creating new data set
Hotel_Bookings2 <- Hotel_Bookings[,-c(33,34,35,36)]
str(Hotel_Bookings2) # Validating removal

# From this removal, the data set contains 119390 observations and 32 columns. The columns are of integer, numeric, and character data types
# with information such as Hotel type, number of stays, cancellation status, patrons, average daily rate, and other hotel booking related information

## Getting to know some variables and their contents
Hotel_Bookings2 %>% 
  select(hotel) %>% 
  count(hotel) %>% 
  view()
# This data set contains information on Resort and City type hotels. From the table, City hotels are the most popular of the two

Hotel_Bookings2 %>% 
  select(is_canceled) %>% 
  count(is_canceled) %>% 
  view()
# The data set contains a binary system. 0 is for bookings that were not cancelled and 1 is for bookings that were cancelled. 

Hotel_Bookings2 %>% 
  select(lead_time) %>% 
  count(lead_time) %>% 
  arrange(desc(n)) %>% 
  view()
# Lead_time is a variable that contains information about the number of days leading up to the time of check in.
# Interesting shows ranges of check ins from the same day to even as long as over two years! Also shows that most people
# have no lead time and less people tend to book in advance.

Hotel_Bookings2 %>% 
  select(arrival_date_day_of_month,arrival_date_week_number,arrival_date_month,arrival_date_year) %>% 
  group_by(arrival_date_day_of_month,arrival_date_week_number,arrival_date_month,arrival_date_year) %>% 
  arrange(arrival_date_year) %>% 
  view()
# This shows the timeline in which this data is collected. It is collect from July 2015 to August 2017

Hotel_Bookings2 %>%
  select(adults, children, babies) %>%
  summarise(
    adults_sum = sum(adults, na.rm = TRUE),
    children_sum = sum(children, na.rm = TRUE),
    babies_sum = sum(babies, na.rm = TRUE)
  )
# Shows me the demographics the types of people, adults, children, and babies. Shows that there were 221636 adults,
# 12403 children, 949 babies

Hotel_Bookings2 %>%
  select(stays_in_week_nights, stays_in_weekend_nights) %>%
  summarise(
    weekend_nights = sum(stays_in_weekend_nights, rm.na = TRUE),
    week_nights = sum(stays_in_week_nights, rm.na = TRUE)
  ) %>% 
  view()
# Shows the total number of weekend nights and week nights by patrons. More people spend their nights during the week than those on the weekend.

Hotel_Bookings2 %>%
  select(meal) %>%
  group_by(meal) %>% 
  count() %>% 
  view()
# Shows the counts of each type of food ordered by patrons. There are 5 meal types, BB, FB, SC, HB, and undefined with BB being the most popular.

Hotel_Bookings2 %>% 
  select(country) %>% 
  group_by(country) %>% 
  count() %>% 
  view()
# Shows the countrys in which the hotels were booked. It is in a 3 character code and does contain an empty cell. Will come back to this in data cleaning

Hotel_Bookings2 %>% 
  select(market_segment) %>% 
  group_by(market_segment) %>% 
  count() %>% 
  view()
# Shows the different market segements in which the hotel bookings were made. Shows 8 groups by one is "undefined". 
# Online TA is the most popular market segement

Hotel_Bookings2 %>% 
  select(distribution_channel) %>% 
  group_by(distribution_channel) %>% 
  count() %>% 
  view()
# Shows distribution channels and there is 5 groups with one of them being undefined

Hotel_Bookings2 %>% 
  select(is_repeated_guest) %>% 
  group_by(is_repeated_guest) %>% 
  count() %>% 
  view()
# This is another binary variable which classifies if a person is a repeat guest. 1 suggests they are and 0 is no

Hotel_Bookings2 %>% 
  select(previous_cancellations,previous_bookings_not_canceled) %>% 
  unique() %>% 
  view()
# previous_cancellations, as the name implies, shows the number of times a guest has cancelled. Not cancelled bookings variable is the opposite 
# and shows the total number of bookings completed. This appears to be for guests who have some membership with the company

Hotel_Bookings2 %>% 
  select(reserved_room_type) %>% 
  unique() %>% 
  view()
# Shows the different types of rooms guest can reserve. Only coded in a single letter.

Hotel_Bookings2 %>% 
  select(assigned_room_type) %>% 
  unique() %>% 
  view()
# This column shows the rooms guests were actually signed at the day of check in.

Hotel_Bookings2 %>% 
  select(booking_changes) %>% 
  view()
# Shows the number of booking changes for each booking. Perhaps this is relational to previous two columns.

Hotel_Bookings2 %>% 
  select(deposit_type) %>% 
  group_by(deposit_type) %>% 
  count() %>% 
  view()
# Shows 3 deposit_types for the bookings, No deposit, Non refundable, and refundable. Most deposit types were No deposit type.

Hotel_Bookings2 %>% 
  select(agent,company) %>% 
  group_by(agent, company) %>% 
  count() %>% 
  view()
# Shows the various agents and companies associated with each booking. 

Hotel_Bookings2 %>% 
  select(customer_type) %>% 
  group_by(customer_type) %>% 
  count() %>% 
  view()
# Shows 4 different types of customers that do hotel bookings with transient being the most.

Hotel_Bookings2 %>% 
  select(adr) %>% 
  group_by(adr) %>% 
  count() %>% 
  view()
# Shows the average daily rate. Upon viewing the data, I notice some interesting values. I will come back to this in data cleaning.

Hotel_Bookings2 %>% 
  select(required_car_parking_spaces) %>%
  group_by(required_car_parking_spaces) %>% 
  count() %>% 
  view()
# Shows the number of parking spaces required by each booking. Shows most guests do not require parking spaces and
# as the number of required spaces increases, fewer people require more.

Hotel_Bookings2 %>% 
  select(reservation_status) %>%
  group_by(reservation_status) %>% 
  count() %>% 
  view()
# Shows 3 different types of reservation status. I'm assuming that Cancelled means the person cancelled their reserved room, Check-out
# means that the booking was complete and the guest left. No show I believe means that the person reserved the room but 
# never cancelled or checked out. will explore this later.

## After getting familiar with this data, I will now move onto cleaning the data to prepare for analysis

################################################### Data Cleaning ###################################################

## Removing Duplicates

Hotel_Bookings2 <- Hotel_Bookings2 %>% 
  distinct() %>% 
  view()
# After using the distinct function, the number of observations went from 119k to 87k.

## Missing or Blank Values

# Looking at rows which contain missing values
Hotel_Bookings2 %>% 
  filter(!complete.cases(.)) %>% 
  view()
Hotel_Bookings2 %>% select(agent,company,distribution_channel,market_segment) %>%  unique() %>% drop_na() %>%  view()
# Agents and company contain missing values. After further insight into the columns, I used some other columns that could
# possibly help connect the company and agent. However, it does not seem like a pattern. I will go forward with removing the agent
# and company column since this does not seem relevant to my future analysis.

# Removing Agent and Company
Hotel_Bookings2 <- Hotel_Bookings2[,-c(24,25)]
# From this removal the number of columns goes from 32 to 30.

# Checking for more NAs within my dataset
Hotel_Bookings2 %>% 
  filter(!complete.cases(.)) %>% 
  view()
# The only NAs left are contained in the children column. There is no other available information to use to help populate the data. 
# From this I will decide to leave the NAs as is for data integrity purposes and not assume things with the data.
# If I needed, I will use mice to impute the missing values.

Hotel_Bookings2 %>% 
  filter(complete.cases(.)) %>% 
  view()
# Shows the data that has rows complete with information. 
str(Hotel_Bookings2)

# Checking other columns for unusual/questionable data
summary(Hotel_Bookings2$lead_time) # Nothing concerning with this.

summary(Hotel_Bookings2$arrival_date_week_number) 
Hotel_Bookings2 %>% 
  arrange(desc(arrival_date_month)) %>% 
  filter(arrival_date_week_number == 53) %>% 
  view()
Hotel_Bookings2$arrival_date_week_number[Hotel_Bookings2$arrival_date_week_number == 53] <- 52
view(Hotel_Bookings2)
# I noticed that there is 53 weeks in the data set. While it is possible to have 53 weeks, to keep this consist I will change this to 52

summary(Hotel_Bookings2$arrival_date_day_of_month) # Looks good
summary(Hotel_Bookings2$stays_in_weekend_nights)
Hotel_Bookings2 %>%
  filter(stays_in_weekend_nights == 19) %>% 
  view()
Hotel_Bookings2 %>%
  arrange(desc(stays_in_weekend_nights)) %>% 
  view()
# I noticed the high number of weekend nights and some people with high week nights. I will leave these values alone as it is possible to have a long-term stay
# possibly due to a long vacation or just in need of somewhere to stay for some unknown reason.
summary(Hotel_Bookings2$adults)
Hotel_Bookings2 %>%
  arrange(desc(adults)) %>% 
  view()
# Noticed a high values of adults, from there I viewed the entire data set and using other columns it is shown as a group booking. From this I will leave the column
Hotel_Bookings2 %>%
  filter(country == "") %>% 
  view()
Hotel_Bookings2 <- Hotel_Bookings2 %>%
  mutate(country = ifelse(country == "", "Other", country))

Hotel_Bookings2 <- Hotel_Bookings2 %>%
  mutate(across(c(market_segment, distribution_channel), ~ ifelse(. == "Undefined", "Other", .))) %>% 
  view()
# Here I change an empty cell found in country and assign it value and I also noticed that in market and distribution channels they contain a 
# "Undefined" category. I changed to "Other" so it would be easier to interpret 

Hotel_Bookings2 %>% 
 arrange(adr) %>% 
  view()
Hotel_Bookings2 <- Hotel_Bookings2 %>% 
  filter(adr <= 0) %>% 
  view()
Hotel_Bookings2 <- Hotel_Bookings2 %>% 
  mutate(adr = ifelse(adr == 5400, 540,adr)) %>% 
  view()
# I noticed some strange values for hotel ADRs. I opt to remove some values. From doing further research, ADR
# or Average Daily Rate is the average price paid per occupied room that day. This data set contains
# adr values from 0 - 540. It can be assumed that 0 means someone had a room free of charge. Could be promotional, vouchers,
# or employees using the rooms for free. 
Hotel_Bookings2 %>% 
  mutate(over_50 = adr >= 50,
         less_50 = adr < 50) %>%
  select(over_50,less_50) %>% 
  count(over_50) %>% 
  view()
# Here I look to see adrs where they are greater than 50 and less than 50. I want to see how these are distributed. 
# Without the ability to seek further information, I will just opt to keep these values however I do understand they can possibly skew some values.
# However they still provide insights into other information that it is better to keep these values. I want to avoid removing as much as possible.


################################################### Data Manipulation ###################################################

## Standardizing the data

str(Hotel_Bookings2)
# Viewing the structure of the data set and changing data types 

Hotel_Bookings2 <- Hotel_Bookings2 %>% 
  mutate(hotel = as.factor(hotel),
         is_canceled = as.factor(is_canceled),
         is_repeated_guest = as.factor(is_repeated_guest),
         meal = as.factor(meal),
         reservation_status = as.factor(reservation_status),
         customer_type = as.factor(customer_type),
         deposit_type = as.factor(deposit_type),
         country = as.factor(country),
         market_segment = as.factor(market_segment),
         distribution_channel = as.factor(distribution_channel),
         reserved_room_type = as.factor(reserved_room_type),
         assigned_room_type = as.factor(assigned_room_type))
str(Hotel_Bookings2)
# Changed some variables from chr to categorical variable type. Some follow a binary system so this is a more appropriate data type

Hotel_Bookings2 <- Hotel_Bookings2 %>%
  mutate(arrival_date_month =recode(arrival_date_month, 
                                    "January" = 1,
                                    "February" = 2,
                                    "March" = 3,
                                    "April" = 4,
                                    "May" = 5,
                                    "June" = 6,
                                    "July" = 7,
                                    "August" = 8,
                                    "September" = 9,
                                    "October" = 10,
                                    "November" = 11,
                                    "December" = 12)) %>%
  view()
# Changed the months from characters out to numeric values for keeping the rest of the date the same style as the rest of the 
# other date related values and easier to use.

Hotel_Bookings2 <- Hotel_Bookings2 %>%
  mutate(meal = recode(meal, "Undefined" = "Other")) %>% 
  view()

# Combining date columns into one 
Hotel_Bookings2 <- Hotel_Bookings2 %>%
  mutate(arrival_date = as.Date(paste(arrival_date_year, arrival_date_month, arrival_date_day_of_month, sep = "-"))) %>% 
  view()
Hotel_Bookings2 <- Hotel_Bookings2[,-c(4,5,6,7)]
str(Hotel_Bookings2)
Hotel_Bookings2 <- Hotel_Bookings2 %>% 
  mutate(reservation_status_date = as.Date(reservation_status_date))
str(Hotel_Bookings2)

# Here I combine the date related information into one column for easier readability and just to standardize
# the column in relation to the reservation date column. I also did a data type change from chr to date
# for the appropriate change. Also removed the weeks column since it isn't really needed and just overkill. 
# date will suffice.

#################################### Summary/Descriptive Statistics ###################################################

## After all cleaning and preparing the data, I can now begin some descriptive statistics and know its accurate

# Creating a table that shows min,avg,max, and range of the lead_time by each hotel
Lead_Time_Summary <- Hotel_Bookings2 %>% 
  drop_na() %>% 
  group_by(hotel) %>% 
  summarize(
    Minimum = min(lead_time),
    Average = round(mean(lead_time)),
    Maximum = max(lead_time),
    Difference = max(lead_time)-min(lead_time)) %>% 
  view()
# Table shows statistics based on each hotel type. Both hotel types share the same minimum lead time or number of days till check in
# On average, people book 78 days leading up to the check in date while people books 83 days leading up to checking date.
# The high values that people will book in advance for resort hotels is 737 days and city is 629 days
# Update: Every code has been updated to reflect reservations that were NOT cancelled to reflect accurate numbers

Hotel_Occupancy <- Hotel_Bookings2 %>% 
  drop_na() %>% 
  mutate(
      arrival_year = year(arrival_date),
      arrival_month = month(arrival_date, label = TRUE, abbr = FALSE)
  ) %>% 
  group_by(hotel,arrival_year,arrival_month) %>% 
  summarize(
    Total_Number_of_Bookings = n(),
    Total_Actual_Bookings = sum(is_canceled==0),
    .groups = "drop") %>% 
  view()

Overall_Occupancy <- Hotel_Bookings2 %>%
  drop_na() %>%
  mutate(
    arrival_year = year(arrival_date),
    arrival_month = month(arrival_date, label = TRUE, abbr = FALSE)
  ) %>%
  group_by(arrival_year, arrival_month) %>%
  summarise(
    Total_Number_of_Bookings = n(),
    Total_Actual_Bookings = sum(is_canceled == 0),
    .groups = 'drop'
  ) %>% 
  
  pivot_longer(cols = c(Total_Number_of_Bookings, Total_Actual_Bookings),
               names_to = "Booking_Type",
               values_to = "Count")
# These are tables that relate to total number of guests. First one is broken down by hotel,year,and month whilst the 2nd
# is just broken down by year and month

Monthly_ADR <-Hotel_Bookings2 %>% 
  drop_na() %>% 
  mutate(
    arrival_year = year(arrival_date),
    arrival_month = month(arrival_date, label = TRUE, abbr = FALSE)
  ) %>% 
  group_by(arrival_year,arrival_month) %>% 
  summarize(
    ADR = mean(adr),
    .groups = "drop"
  ) %>% 
  pivot_wider(names_from = arrival_year, values_from = ADR) %>% 
  view()
# Shows the Average ADR per month. Shows that ADR is lower in off-peak seasons but highest in the summer months. I Won't filter out
# the adr of those that didn't complete their booking because the ADR is still usefull regardless of completion of the booking

Monthly_Cancellations <- Hotel_Bookings2 %>%
  drop_na() %>% 
  mutate(
    arrival_year = year(arrival_date),
    arrival_month = month(arrival_date, label = TRUE, abbr = FALSE)
  ) %>% 
  group_by(arrival_year,arrival_month) %>%
  filter(is_canceled == 1) %>% 
  summarise(
    Total_Num_of_Cancellations = n(),.groups = "drop") %>% 
  pivot_wider(names_from = arrival_year, values_from = Total_Num_of_Cancellations)

# Tables show number of cancellations each month by each year 

# Showing Revenue for bookings that were not cancelled. However, it is also possible to see the possible revenue to have gained
# from the cancelled bookings. This could be useful for marketing to use to find strategies to capture that lost revenue 
# either through discounts or vouchers or promotional offerings

# Adding Calculated columns for further insights
Hotel_Revenue <- Hotel_Bookings2 %>% 
  drop_na() %>% 
  filter(is_canceled == 0) %>% 
  mutate(
    total_nights = stays_in_weekend_nights+stays_in_week_nights,
    booking_revenue = adr * total_nights) %>% 
  view()

# Investigating Monthly revenue.
Monthly_Revenue <- Hotel_Revenue %>% 
  mutate(
    arrival_year = year(arrival_date),
    arrival_month = month(arrival_date, label = TRUE, abbr = FALSE)
  ) %>% 
  group_by(arrival_year, arrival_month) %>% 
  summarise(
    Total_Revenue = sum(booking_revenue),
    .groups = "drop"
  ) %>% 
  pivot_wider(names_from = arrival_year, values_from = Total_Revenue)

# Now I will break down this revenue table further to see the health of each hotel type
Monthly_Revenue_By_Hotel <- Hotel_Revenue %>% 
  mutate(
    arrival_year = year(arrival_date),
    arrival_month = month(arrival_date, label = TRUE, abbr = FALSE)
  ) %>% 
  group_by(hotel,arrival_year, arrival_month) %>% 
  summarise(
    Total_Revenue = sum(booking_revenue),
    .groups = "drop"
  )

# Now lets see what our customer type breakdown, how much revenue is collected from each group, and find where they booking from
Customer_Type_Revenue <- Hotel_Revenue %>% 
  group_by(customer_type) %>% 
  summarise(
    Total_Customers = n(),
    Total_Revenue = sum(booking_revenue),
    Average_Revenue = mean(booking_revenue)
) %>% 
  view()
Market_Revenue<- Hotel_Revenue %>% 
  group_by(market_segment) %>% 
  summarise(
    Total_Market_Bookings = n(),
    Total_Revenue = sum(booking_revenue),
    Average_Revenue = mean(booking_revenue)) %>% 
    view()

Channel_Revenue<- Hotel_Revenue %>% 
  group_by(distribution_channel) %>% 
  summarise(
    Total_Channel_Bookings = n(),
    Total_Revenue = sum(booking_revenue),
    Average_Revenue = mean(booking_revenue)) %>% 
  view()

# After doing some descriptive statistics, now I will visualize my findings to better tell the story of this data!

############################################## Data Visualizations ###################################################

# Load library
library(ggplot2)

# This is a timeline of the all bookings from July 2015 to August 2017
Overall_Bookings_Plot <- ggplot(data = Overall_Occupancy, mapping = aes(x = interaction(arrival_month, arrival_year, sep = "-"), y = Count, color = Booking_Type, group = Booking_Type)) +
  geom_point() +
  geom_line() +
  labs(title = "Total and Actual Number of Bookings Over Time",
       x = "Year-Month",
       y = "Number of Bookings") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  scale_color_manual(values = c("Total_Number_of_Bookings" = "purple", "Total_Actual_Bookings" = "blue"), 
                     labels = c("Total Bookings", "Actual Bookings"))
# This plot displays the total number of bookings (cancelled or not) and 
# a second one which reflects all completed bookings. The gap is the difference
# which reflects cancellations.

# This is the same plot however a stacked plot where we can distinguish between each hotel type
Hotel_Type_Plot <- ggplot(data = Hotel_Occupancy, aes(x = interaction(arrival_month, arrival_year, sep = "-"), y = Total_Actual_Bookings, group = hotel, colour = hotel)) +
  geom_point()+
  geom_line() +
  labs(title = "Total Number of Bookings Over Time",
       x = "Year-Month",
       y = "Number of Bookings",
       fill = "Hotel") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
# IMPORTANT: This plot reflects data of hotel bookings that were not cancelled.
# Key Takeaways: Resort Hotels are more stable however City Hotels are more popular

Monthly_ADR_Plot <- ggplot(data = Monthly_ADR, mapping = aes(x = interaction(arrival_month,arrival_year, sep = "-"), y = ADR, group = 1)) +
  geom_col(fill = "lightblue") +
  geom_line(colour = "red", linewidth = 1.5)+
  labs(title = "ADR per Month Over Time",
       x = "Year-Month",
       y = "Average Daily Rate (ADR)")+
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
# This barplot reflects the average of the adr for each month and each year. A line
# is also layered to emphasize the trend in data.

Monthly_Revenue <- Hotel_Revenue %>% 
  mutate(
    arrival_year = year(arrival_date),
    arrival_month = month(arrival_date, label = TRUE, abbr = FALSE)
  ) %>% 
  group_by(arrival_year, arrival_month) %>% 
  summarise(
    Total_Revenue = sum(booking_revenue),
    .groups = "drop"
  ) 
Monthly_Revenue_Plot <- ggplot(data = Monthly_Revenue, mapping = aes(x = interaction(arrival_month,arrival_year), y = Total_Revenue, group = 1))+
  geom_point(colour = "purple")+
  geom_line(colour = "purple")+
  labs(title = "Monthly Revenue Over Time",
       x = "Year-Month",
       y = "Revenue")+
  theme_minimal()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
#IMPORTANT: I copied my code for the monthly revenue however I made an adjustment to be able to produce the visualization
# by removing the pivot wider function. 
# Key takeaways: This shows the overall trend of total revenue. It is very evident that 
# summer months tend to perform the best in comparison to the other 3 seasons. 
# Hotel revenue each summer period tends to perform better than the previous peak season
# and that goes for each other season as well.

Monthly_Revenue_By_Hotel <- Hotel_Revenue %>% 
  mutate(
    arrival_year = year(arrival_date),
    arrival_month = month(arrival_date, label = TRUE, abbr = FALSE)
  ) %>% 
  group_by(hotel,arrival_year, arrival_month) %>% 
  summarise(
    Total_Revenue = sum(booking_revenue),
    .groups = "drop"
  )
Monthly_Revenue_By_Hotel_Plot <- ggplot(data = Monthly_Revenue_By_Hotel, mapping = aes(x = interaction(arrival_month,arrival_year, sep = "-"), y = Total_Revenue, group = hotel, color = hotel))+
  geom_point()+
  geom_line()+
  labs(title = "Monthly Revenue Over Time by Hotel Type",
       x = "Year-Month",
       y = "Revenue ")+
  scale_y_continuous(label = scales::dollar_format(scale = 0.001,suffix = "K"))+
  theme_minimal()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
# Key takeaways: Both Hotels generally perform similarly however,
# it is evident that resort hotels generate the most revenue for the business with 
# peak times happening in the summer months. City hotels however perform better in off-peak
# seasons. 
Customer_Type_Revenue <- Hotel_Revenue %>% 
  filter(is_canceled == 0) %>% 
  group_by(customer_type) %>% 
  summarise(
    Total_Customers = n(),
    Total_Revenue = sum(booking_revenue),
    Average_Revenue = mean(booking_revenue)
  ) 
Customer_Type_Plot <- ggplot(data = Customer_Type_Revenue, mapping = aes(x = customer_type, y = Total_Customers, fill = customer_type))+
  geom_col()+
  geom_text(aes(label = scales::dollar(Total_Revenue)), vjust = -0.5, colour = "black", size = 3.5) +
  labs(title = "Total Revenue By Customer Type",
       x = "Customer Type",
       y = "Number of Customers",
       fill = "Customer Type")+
  theme_minimal()+
  theme(axis.text.x = element_text(angle = 45, hjust =1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

Market_Revenue<- Hotel_Revenue %>% 
  group_by(market_segment) %>% 
  summarise(
    Total_Market_Bookings = n(),
    Total_Revenue = sum(booking_revenue),
    Average_Revenue = mean(booking_revenue))
Market_Revenue_Plot <- ggplot(data = Market_Revenue, mapping = aes(x = market_segment, y = Total_Market_Bookings, fill = market_segment)) +
  geom_col()+
  geom_text(aes(label = scales::dollar(Total_Revenue)), vjust = -0.5, colour = "black", size = 3.5) +
  labs(title = "Total Revenue By Market Segment",
       x = "Market Segment",
       y = "Number of Bookings",
       fill = "Market Segment") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

Channel_Revenue<- Hotel_Revenue %>% 
  group_by(distribution_channel) %>% 
  summarise(
    Total_Channel_Bookings = n(),
    Total_Revenue = sum(booking_revenue),
    Average_Revenue = mean(booking_revenue)) %>% 
  view()
Channel_Revenue_Plot <- ggplot(data = Channel_Revenue, mapping = aes(x = distribution_channel, y = Total_Channel_Bookings, fill = distribution_channel)) +
  geom_col()+
  geom_text(aes(label = scales::dollar(Total_Revenue)), vjust = -0.5, colour = "black", size = 3.5) +
  labs(title = "Total Revenue By Distribution Channel",
       y = "Number of Bookings",
       fill = "Market Segment") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

######################################################################################


  

