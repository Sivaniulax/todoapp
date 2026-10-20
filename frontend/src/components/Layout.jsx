import { Outlet } from 'react-router-dom'
import GuestBanner from './GuestBanner'
import Navbar from './Navbar'

export default function Layout() {
  return (
    <div className="app">
      <Navbar />
      <GuestBanner />
      <main className="container">
        <Outlet />
      </main>
      <footer className="footer">TodoApp · Rails API + React</footer>
    </div>
  )
}
