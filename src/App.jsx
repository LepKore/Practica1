import { useState, useEffect } from 'react'
import ProductCard from './ProductCard'
import Cart from './Cart'
import './App.css'

const API_URL = 'https://dummyjson.com/products'
const CATEGORIES = ['beauty', 'fragrances', 'furniture', 'groceries']

function App() {
  const [products, setProducts] = useState([])
  const [cart, setCart] = useState([])
  const [search, setSearch] = useState('')
  const [category, setCategory] = useState('all')
  const [loading, setLoading] = useState(true)
  const [showCart, setShowCart] = useState(false)

  useEffect(() => {
    setLoading(true)
    const url = search
      ? `${API_URL}/search?q=${encodeURIComponent(search)}`
      : `${API_URL}?limit=30`

    fetch(url)
      .then((res) => res.json())
      .then((data) => {
        setProducts(data.products)
        setLoading(false)
      })
  }, [search])

  function addToCart(product) {
    setCart((currentCart) => {
      const existing = currentCart.find((item) => item.id === product.id)

      if (existing) {
        if (existing.quantity >= existing.stock) return currentCart

        return currentCart.map((item) =>
          item.id === product.id ? { ...item, quantity: item.quantity + 1 } : item
        )
      }

      if (product.stock <= 0) return currentCart

      return [...currentCart, { ...product, quantity: 1 }]
    })
  }

  function changeQty(index, delta) {
    setCart((currentCart) =>
      currentCart
        .map((item, i) => {
          if (i !== index) return item
          const next = item.quantity + delta
          if (delta > 0 && next > item.stock) return item
          return { ...item, quantity: next }
        })
        .filter((item) => item.quantity > 0)
    )
  }

  function removeFromCart(item) {
    setCart((currentCart) => currentCart.filter((c) => c.id !== item.id))
  }

  function checkout() {
    alert(`Compra realizada. Total: $${total.toFixed(2)}`)
    setProducts((currentProducts) =>
      currentProducts.map((product) => {
        const purchased = cart.find((item) => item.id === product.id)
        return purchased
          ? { ...product, stock: product.stock - purchased.quantity }
          : product
      })
    )
    setCart([])
  }

  const total = cart.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0
  )

  const visibleProducts = products
    .filter((p) => category === 'all' || p.category === category)
    .filter((p) => p.title.toLowerCase().includes(search.toLowerCase()))

  return (
    <div className={`app${showCart ? ' cart-open' : ''}`}>
      <header className="header">
        <h1>Tienda Tech</h1>
        <input
          className="search"
          type="search"
          aria-label="Buscar productos"
          placeholder="Buscar..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
        <select
          aria-label="Filtrar por categoría"
          value={category}
          onChange={(e) => setCategory(e.target.value)}
        >
          <option value="all">Todas</option>
          {CATEGORIES.map((c) => (
            <option key={c} value={c}>
              {c}
            </option>
          ))}
        </select>
        <button
          className="cart-btn"
          onClick={() => setShowCart((visible) => !visible)}
          aria-expanded={showCart}
        >
          {showCart ? 'Ocultar carrito' : `Carrito (${cart.length})`}
        </button>
      </header>

      <main>
        {loading && <p className="loading">Cargando...</p>}

        {!loading && visibleProducts.length === 0 && <p>Sin resultados.</p>}

        <div className="grid">
          {visibleProducts.map((p) => (
            <ProductCard
              key={p.id}
              product={p}
              onAdd={() => addToCart(p)}
              disabled={p.stock === 0}
            />
          ))}
        </div>
      </main>

      {showCart && (
        <Cart
          items={cart}
          total={total}
          onQty={changeQty}
          onRemove={removeFromCart}
          onCheckout={checkout}
        />
      )}
    </div>
  )
}

export default App
