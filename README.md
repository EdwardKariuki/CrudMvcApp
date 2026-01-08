# CrudMvcApp

A modern ASP.NET Core MVC web application for managing products with full CRUD (Create, Read, Update, Delete) operations. This application demonstrates best practices for building scalable MVC applications with Entity Framework Core.

## 🚀 Features

- **Product Management**: Complete CRUD operations for products
- **Product Details**: View detailed information about each product
- **Soft Delete**: Products are marked as deleted instead of being permanently removed
- **Product Tracking**: Tracks creation date, update date, and who updated each product
- **Modern UI**: Clean and responsive interface using Bootstrap
- **Docker Support**: Containerized application ready for deployment
- **Entity Framework Core**: Uses EF Core with InMemory database (can be easily switched to SQL Server, PostgreSQL, etc.)

## 🛠️ Technologies Used

- **.NET 9.0** - Latest .NET framework
- **ASP.NET Core MVC** - Web framework
- **Entity Framework Core 7.0** - ORM for data access
- **Bootstrap 5** - Frontend framework for styling
- **jQuery** - JavaScript library for DOM manipulation
- **Docker** - Containerization platform

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- [.NET 9.0 SDK](https://dotnet.microsoft.com/download/dotnet/9.0) or later
- [Docker Desktop](https://www.docker.com/products/docker-desktop) (optional, for containerized deployment)
- A code editor (Visual Studio, VS Code, Rider, etc.)

## 📦 Installation

### Clone the Repository

```bash
git clone https://github.com/EdwardKariuki/CrudMvcApp.git
cd CrudMvcApp/CrudMvcApp
```

### Restore Dependencies

```bash
dotnet restore
```

## 🏃 Running the Application

### Option 1: Using .NET CLI (Development)

```bash
dotnet run
```

The application will be available at:
- HTTP: `http://localhost:5261`
- HTTPS: `https://localhost:7050`

### Option 2: Using Docker (Recommended for Production-like Environment)

#### Build the Docker Image

```bash
docker build -t crudmvcapp .
```

#### Run the Container

```bash
docker run -p 8080:8080 crudmvcapp
```

#### Using Docker Compose (Easiest)

```bash
docker-compose up --build
```

The application will be available at `http://localhost:8080`

#### Run in Background (Detached Mode)

```bash
docker-compose up -d
```

#### Stop the Application

```bash
docker-compose down
```

#### View Logs

```bash
docker-compose logs -f
```

## 📁 Project Structure

```
CrudMvcApp/
├── Controllers/          # MVC Controllers
│   ├── HomeController.cs # Home and error pages
│   └── ProductController.cs # Product CRUD operations
├── Models/               # Data models
│   ├── Product.cs        # Product entity
│   ├── ProductContext.cs # DbContext for EF Core
│   └── ErrorViewModel.cs # Error view model
├── Views/                # Razor views
│   ├── Home/             # Home page views
│   ├── Product/          # Product management views
│   │   ├── Index.cshtml  # Product list
│   │   ├── Create.cshtml # Create new product
│   │   ├── Edit.cshtml   # Edit existing product
│   │   ├── Details.cshtml # Product details
│   │   └── Delete.cshtml # Delete confirmation
│   └── Shared/           # Shared layouts and partials
├── wwwroot/              # Static files (CSS, JS, images)
├── Properties/           # Configuration files
├── Program.cs            # Application entry point
├── Dockerfile            # Docker configuration
├── docker-compose.yml    # Docker Compose configuration
└── CrudMvcApp.csproj     # Project file
```

## 🗄️ Data Model

The `Product` model contains the following properties:

- `Id` - Unique identifier
- `Name` - Product name
- `Description` - Product description
- `Price` - Product price (decimal)
- `Quantity` - Available quantity (int)
- `Category` - Product category
- `ImageUrl` - URL to product image
- `CreatedAt` - Creation timestamp
- `UpdatedAt` - Last update timestamp (nullable)
- `Deleted` - Soft delete flag (bool)
- `UpdatedBy` - User who last updated the product

## 🔧 Configuration

### Database

Currently, the application uses **Entity Framework Core InMemory** database. To switch to a different database provider (SQL Server, PostgreSQL, SQLite, etc.), modify the `Program.cs` file:

```csharp
// For SQL Server
builder.Services.AddDbContext<ProductContext>(options =>
    options.UseSqlServer(connectionString));

// For PostgreSQL
builder.Services.AddDbContext<ProductContext>(options =>
    options.UseNpgsql(connectionString));

// For SQLite
builder.Services.AddDbContext<ProductContext>(options =>
    options.UseSqlite(connectionString));
```

### Environment Variables

The application uses standard ASP.NET Core configuration. You can override settings using environment variables or by modifying `appsettings.json` and `appsettings.Development.json`.

## 🧪 Development

### Building the Project

```bash
dotnet build
```

### Running Tests

*Note: Tests can be added to the project structure.*

### Hot Reload

During development, you can use hot reload:

```bash
dotnet watch run
```

## 📝 API Endpoints

The application follows standard MVC routing:

- `GET /` - Home page
- `GET /Product` - List all products
- `GET /Product/Create` - Show create product form
- `POST /Product/Create` - Create new product
- `GET /Product/Details/{id}` - View product details
- `GET /Product/Edit/{id}` - Show edit product form
- `POST /Product/Edit/{id}` - Update product
- `GET /Product/Delete/{id}` - Show delete confirmation
- `POST /Product/Delete/{id}` - Soft delete product

## 🚢 Deployment

### Docker Deployment

The application is containerized and ready for deployment to any Docker-compatible platform:

- Docker Hub
- Azure Container Instances
- AWS ECS/Fargate
- Google Cloud Run
- Kubernetes

### Build for Production

```bash
docker build -t crudmvcapp:latest .
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👤 Author

Your Name

## 🙏 Acknowledgments

- ASP.NET Core team for the excellent framework
- Bootstrap team for the UI framework
- Docker team for containerization tools

