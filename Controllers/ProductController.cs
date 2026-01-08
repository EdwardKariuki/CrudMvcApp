using Microsoft.AspNetCore.Mvc;
using CrudMvcApp.Models;
using System.Linq;
using System.Threading.Tasks;

namespace CrudMvcApp.Controllers
{
    public class ProductController : Controller
    {
        private readonly ProductContext _context;

        public ProductController(ProductContext context)
        {
            _context = context;
        }

        // GET: Product
        public IActionResult Index()
        {
            var products = _context.Products.Where(p => !p.Deleted).ToList();
            return View(products);
        }

        // GET: Product/Details/5
        public IActionResult Details(int? id)
        {
            if (id == null) return NotFound();
            var product = _context.Products.FirstOrDefault(m => m.Id == id);
            if (product == null) return NotFound();
            return View(product);
        }

        // GET: Product/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Product/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create([Bind("Name,Description,Price,Quantity,Category,ImageUrl,UpdatedBy")] Product product)
        {
            if (ModelState.IsValid)
            {
                product.CreatedAt = DateTime.Now;
                product.UpdatedAt = DateTime.Now;
                _context.Add(product);
                _context.SaveChanges();
                return RedirectToAction(nameof(Index));
            }
            return View(product);
        }

        // GET: Product/Edit/5
        public IActionResult Edit(int? id)
        {
            if (id == null) return NotFound();
            var product = _context.Products.Find(id);
            if (product == null) return NotFound();
            return View(product);
        }

        // POST: Product/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Edit(int id, [Bind("Id,Name,Description,Price,Quantity,Category,ImageUrl,CreatedAt,UpdatedBy,Deleted")] Product product)
        {
            if (id != product.Id) return NotFound();
            if (ModelState.IsValid)
            {
                var existing = _context.Products.Find(id);
                if (existing == null) return NotFound();
                existing.Name = product.Name;
                existing.Description = product.Description;
                existing.Price = product.Price;
                existing.Quantity = product.Quantity;
                existing.Category = product.Category;
                existing.ImageUrl = product.ImageUrl;
                existing.UpdatedAt = DateTime.Now;
                existing.UpdatedBy = product.UpdatedBy;
                existing.Deleted = product.Deleted;
                _context.SaveChanges();
                return RedirectToAction(nameof(Index));
            }
            return View(product);
        }

        // GET: Product/Delete/5
        public IActionResult Delete(int? id)
        {
            if (id == null) return NotFound();
            var product = _context.Products.FirstOrDefault(m => m.Id == id);
            if (product == null) return NotFound();
            return View(product);
        }

        // POST: Product/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public IActionResult DeleteConfirmed(int id)
        {
            var product = _context.Products.Find(id);
            if (product != null)
            {
                product.Deleted = true;
                product.UpdatedAt = DateTime.Now;
                _context.SaveChanges();
            }
            return RedirectToAction(nameof(Index));
        }
    }
} 