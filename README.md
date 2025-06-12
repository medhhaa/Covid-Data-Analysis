# Covid-Data-Analysis

## 🗂️ Project Overview

This project explores the global COVID-19 dataset from [Our World in Data (OWID)](https://docs.owid.io/projects/covid/en/latest/dataset.html) using SQL to derive meaningful insights. It is implemented in **Azure Data Studio** on macOS via a Dockerized SQL Server environment, with an alternative setup using SSMS for Windows users.

### 📊 About the Dataset
The data used in this project is from the [OWID COVID-19 dataset](https://docs.owid.io/projects/covid/en/latest/dataset.html), maintained by the Global Change Data Lab and the OWID team. This open-access resource compiles data from trusted sources like the WHO, CDC, ECDC, and national health departments, including:
- Case numbers
- Testing rates
- Hospitalizations
- Deaths
- Vaccination statistics

These indicators are standardized to support global comparability.

### 🙏 A Big Thank You
Huge thanks to **Our World in Data** for their dedication to open-access data and empowering global research.

## 🛠️ Project Highlights
- 📈 Analyzes global trends in COVID-19 cases, deaths, and vaccinations
- 💀 Calculates fatality and infection rates across countries and continents
- ⚠️ Identifies high-risk countries based on severity and vaccine coverage
- 🧱 Uses CTEs, temp tables, window functions, and views for organized, modular SQL analysis
- 🧩 Designed for adaptability with BI tools like Tableau and Power BI

## ⚙️ Tools Used
- Azure Data Studio with Docker (macOS)
- SQL Server Management Studio (SSMS) for Windows
- SQL Server 2019 (via Docker container or local install)

## 🔧 Setup Instructions

### 📌 For Mac Users
1. Install Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop)
2. Run a SQL Server container:
   ```bash
   docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourStrong@Pass123" -p 1433:1433 --name sql_server_container -d mcr.microsoft.com/mssql/server:2019-latest
   ```
   **🔐 Password requirements:**
   - At least 8 characters (recommended: 12+)
   - Include uppercase, lowercase, number, and a symbol
   - Example: `YourStrong@Pass123`
3. Download and install [Azure Data Studio](https://learn.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio)
4. Connect using:
   - **Server:** `localhost`
   - **Username:** `sa`
   - **Password:** `YourStrong@Pass123`

### 📌 For Windows Users
1. Install SQL Server Express and SQL Server Management Studio (SSMS)
2. Launch SSMS and connect to `localhost\SQLEXPRESS` using SQL authentication

## ⚠️ Common Errors and Fixes
- 🟥 **Red underlines / ghost errors:**
  - Refresh IntelliSense Cache (Ctrl+Shift+R)
- 🛑 **Insert errors (column mismatch):**
  - Ensure SELECT column order matches table schema
- 💥 **Divide by zero:**
  - Use `NULLIF`: `(total_deaths * 100.0) / NULLIF(total_cases, 0)`
- 🔁 **Duplicate tables or schema mismatch:**
  - Drop outdated versions and refresh IntelliSense
- 🧠 **Missing data / NULLs:**
  - Add filters such as `WHERE continent IS NOT NULL`

---

🔎 All queries, views, and analyses are in the [`covid_analysis_queries.sql`](./covid_analysis_queries.sql) file included in this repository.

Happy querying! 💻📊
