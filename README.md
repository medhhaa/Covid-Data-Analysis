# Covid-Data-Analysis

-- 🗂️ Project Overview

-- This project explores the global COVID-19 dataset from Our World in Data (OWID) using SQL to derive meaningful insights. 
-- It is implemented in Azure Data Studio on macOS via a Dockerized SQL Server environment, with an alternative setup using SSMS for Windows users.

-- Data Source: Our World in Data (OWID COVID dataset)
-- 📊 About the Dataset: 
-- The data for this project comes from [Our World in Data's COVID-19 dataset](https://docs.owid.io/projects/covid/en/latest/dataset.html).
-- It is a comprehensive, regularly updated open-access dataset maintained by the Global Change Data Lab and the OWID team.
-- Data is sourced from reliable institutions including the WHO, CDC, ECDC, government health ministries, and other public health organizations.
-- It includes metrics like case numbers, testing rates, hospitalizations, deaths, and vaccinations—standardized and structured for global comparison.

-- 🙏 A Big Thank You!
-- Huge thanks to Our World in Data for their commitment to transparency, open data, and empowering the global research community.

-- 🛠️ Project Highlights
-- • Analyzes total cases, deaths, and vaccination trends worldwide
-- • Calculates fatality and infection rates by country and continent
-- • Identifies high-risk countries based on death and vaccination rates
-- • Utilizes CTEs, temp tables, window functions, and views for modular analysis
-- • Designed for clarity, modular reuse, and easy integration into visualization tools

-- ⚙️ Tools Used:
-- • Azure Data Studio with Docker (for Mac users)
-- • SQL Server Management Studio (SSMS) for Windows users
-- • SQL Server 2019 (Docker container or local instance)

-- 🛠️ Want to Try This Project?
-- Set up instructions below will help you recreate the environment:

-- 🔧 Setup Instructions
-- 📌 For Mac Users:
-- 1. Install Docker Desktop from docker.com
-- 2. Run SQL Server container:
--     docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourStrong@Pass123" -p 1433:1433 --name sql_server_container -d mcr.microsoft.com/mssql/server:2019-latest
-- 3. Download and install Azure Data Studio.
-- 4. Connect using:
--     Server: localhost
--     Username: sa
--     Password: YourStrong@Pass123
-- 🔐 NOTE: The SA_PASSWORD must meet SQL Server’s password policy:
--         - At least 8 characters 
--         - Must include uppercase, lowercase, number, and symbol
--         - Example: YourStrong@Pass123

-- 📌 For Windows Users:
-- 1. Install SQL Server Express and SSMS
-- 2. Connect to: localhost\SQLEXPRESS using SQL authentication

-- ⚠️ Common Errors and Fixes:
-- 🟥 Red underlines / ghost errors:
--    → Solution: Refresh IntelliSense Cache (Ctrl+Shift+R)
-- 🛑 Insert errors (column mismatch):
--    → Solution: Match SELECT columns exactly to table structure
-- 💥 Divide by zero:
--    → Solution: Use NULLIF for safe division: (total_deaths * 100.0) / NULLIF(total_cases, 0)
-- 🔁 Duplicate tables or outdated schema:
--    → Solution: Drop duplicates and refresh IntelliSense cache

-- ➕ See the `covid_analysis_queries.sql` file in this repo for all exploratory SQL logic, views, CTEs, and analysis steps.
