import tkinter as tk
from tkinter import messagebox, filedialog
import hashlib
import json
import os
import pyperclip
import random
import string

# ============================================
# 1️⃣ FILE SETUP & DATA FUNCTIONS
# ============================================
DATA_FILE = "passwords.json"

def load_data():
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, "r") as f:
            return json.load(f)
    return {}

def save_data(data):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=4)

# ============================================
# 2️⃣ HASHING & PASSWORD GENERATION
# ============================================
def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

def generate_password(length=12):
    chars = string.ascii_letters + string.digits + string.punctuation
    return ''.join(random.choice(chars) for _ in range(length))

# ============================================
# 3️⃣ GLOBAL VARIABLES
# ============================================
accounts = load_data()
undo_stack = []
show_pw = False  # to toggle password visibility

# ============================================
# 4️⃣ CORE FUNCTIONS
# ============================================
def add_account(site, username, password):
    if site and username and password:
        hashed_pw = hash_password(password)
        accounts[site] = {"username": username, "password": hashed_pw}
        undo_stack.append(site)
        save_data(accounts)
        messagebox.showinfo("Added", f"✅ Account for '{site}' saved successfully!")
    else:
        messagebox.showwarning("Input Error", "⚠ Please fill all fields!")

def search_account(site):
    if site in accounts:
        acc = accounts[site]
        result = f"Username: {acc['username']}\nHashed Password:\n{acc['password']}"
        messagebox.showinfo("Account Found", result)
    else:
        messagebox.showwarning("Not Found", "❌ No account found for this website.")

def undo_last():
    if undo_stack:
        last_site = undo_stack.pop()
        if last_site in accounts:
            del accounts[last_site]
            save_data(accounts)
            messagebox.showinfo("Undo", f"↩ Removed last added site: {last_site}")
    else:
        messagebox.showwarning("Undo", "⚠ No actions to undo!")

def show_all_accounts():
    if accounts:
        all_sites = "\n".join(accounts.keys())
        messagebox.showinfo("All Accounts", f"🗂 Saved Sites:\n\n{all_sites}")
    else:
        messagebox.showinfo("Empty", "No accounts saved yet!")

def copy_password(site):
    if site in accounts:
        pw_hash = accounts[site]["password"]
        pyperclip.copy(pw_hash)
        messagebox.showinfo("Copied", "🔒 Hashed password copied to clipboard!")
    else:
        messagebox.showwarning("Error", "⚠ Site not found!")

def export_data():
    file_path = filedialog.asksaveasfilename(defaultextension=".json",
                                             filetypes=[("JSON Files", "*.json")])
    if file_path:
        save_data(accounts)
        os.replace(DATA_FILE, file_path)
        messagebox.showinfo("Exported", "📦 Data exported successfully!")

def import_data():
    file_path = filedialog.askopenfilename(filetypes=[("JSON Files", "*.json")])
    if file_path:
        with open(file_path, "r") as f:
            imported = json.load(f)
            accounts.update(imported)
            save_data(accounts)
        messagebox.showinfo("Imported", "✅ Data imported successfully!")

# ============================================
# 5️⃣ GUI SETUP
# ============================================
root = tk.Tk()
root.title("🔐 Secure Password Manager")
root.geometry("550x500")
root.config(bg="#f0f8ff")

# Frame styling
frame = tk.Frame(root, bg="white", bd=2, relief="groove")
frame.place(relx=0.5, rely=0.5, anchor="center", width=500, height=430)

# Title label
tk.Label(frame, text="🔐 PASSWORD MANAGER", font=("Segoe UI", 16, "bold"),
         bg="white", fg="#0d47a1").pack(pady=10)

# ============================================
# 6️⃣ INPUT AREA
# ============================================
form = tk.Frame(frame, bg="white")
form.pack(pady=10)

tk.Label(form, text="Website:", bg="white", font=("Segoe UI", 11)).grid(row=0, column=0, pady=5, padx=10, sticky="w")
site_entry = tk.Entry(form, width=35, font=("Segoe UI", 10))
site_entry.grid(row=0, column=1, pady=5)

tk.Label(form, text="Username:", bg="white", font=("Segoe UI", 11)).grid(row=1, column=0, pady=5, padx=10, sticky="w")
user_entry = tk.Entry(form, width=35, font=("Segoe UI", 10))
user_entry.grid(row=1, column=1, pady=5)

tk.Label(form, text="Password:", bg="white", font=("Segoe UI", 11)).grid(row=2, column=0, pady=5, padx=10, sticky="w")
pw_entry = tk.Entry(form, width=35, font=("Segoe UI", 10), show="*")
pw_entry.grid(row=2, column=1, pady=5)

# Show/Hide password toggle
def toggle_password():
    global show_pw
    show_pw = not show_pw
    pw_entry.config(show="" if show_pw else "*")
    toggle_btn.config(text="🙈 Hide" if show_pw else "👁 Show")

toggle_btn = tk.Button(form, text="👁 Show", bg="#eeeeee", command=toggle_password)
toggle_btn.grid(row=2, column=2, padx=5)

# Generate password button
def handle_generate():
    pw = generate_password()
    pw_entry.delete(0, tk.END)
    pw_entry.insert(0, pw)
    pyperclip.copy(pw)
    messagebox.showinfo("Generated", "🔑 Strong password generated & copied!")

tk.Button(form, text="Generate 🔑", bg="#00bcd4", fg="white", command=handle_generate).grid(row=3, column=1, pady=8)

# ============================================
# 7️⃣ BUTTON ACTIONS
# ============================================
def handle_add():
    site = site_entry.get().strip()
    user = user_entry.get().strip()
    pw = pw_entry.get().strip()
    add_account(site, user, pw)
    site_entry.delete(0, tk.END)
    user_entry.delete(0, tk.END)
    pw_entry.delete(0, tk.END)

def handle_search():
    site = site_entry.get().strip()
    if site:
        search_account(site)
    else:
        messagebox.showwarning("Input Error", "Enter a website name!")

def handle_copy():
    site = site_entry.get().strip()
    if site:
        copy_password(site)
    else:
        messagebox.showwarning("Input Error", "Enter a website name!")

# ============================================
# 8️⃣ ACTION BUTTONS AREA
# ============================================
btn_frame = tk.Frame(frame, bg="white")
btn_frame.pack(pady=10)

tk.Button(btn_frame, text="➕ Add", width=10, bg="#4caf50", fg="white", command=handle_add).grid(row=0, column=0, padx=5, pady=5)
tk.Button(btn_frame, text="🔍 Search", width=10, bg="#2196f3", fg="white", command=handle_search).grid(row=0, column=1, padx=5, pady=5)
tk.Button(btn_frame, text="↩ Undo", width=10, bg="#ff9800", fg="white", command=undo_last).grid(row=0, column=2, padx=5, pady=5)
tk.Button(btn_frame, text="📜 Show All", width=10, bg="#9c27b0", fg="white", command=show_all_accounts).grid(row=1, column=0, padx=5, pady=5)
tk.Button(btn_frame, text="📋 Copy", width=10, bg="#607d8b", fg="white", command=handle_copy).grid(row=1, column=1, padx=5, pady=5)
tk.Button(btn_frame, text="⬆ Export", width=10, bg="#03a9f4", fg="white", command=export_data).grid(row=1, column=2, padx=5, pady=5)
tk.Button(btn_frame, text="⬇ Import", width=10, bg="#795548", fg="white", command=import_data).grid(row=2, column=0, padx=5, pady=5)
tk.Button(btn_frame, text="❌ Exit", width=10, bg="#f44336", fg="white", command=root.quit).grid(row=2, column=2, padx=5, pady=5)

# ============================================
# 9️⃣ RUN APP
# ===========================================
root.mainloop()
