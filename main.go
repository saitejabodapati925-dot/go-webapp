package main

import (
	"log"
	"net/http"
)

func homePage(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "static/home.html")
}

func coursePage(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "static/courses.html")
}

func aboutPage(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "static/about.html")
}

func contactPage(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "static/contact.html")
}

func newMux() *http.ServeMux {
	mux := http.NewServeMux()

	mux.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}
		http.Redirect(w, r, "/home", http.StatusFound)
	})
	mux.HandleFunc("/home", homePage)
	mux.HandleFunc("/courses", coursePage)
	mux.HandleFunc("/about", aboutPage)
	mux.HandleFunc("/contact", contactPage)

	return mux
}

func main() {
	err := http.ListenAndServe("0.0.0.0:8080", newMux())
	if err != nil {
		log.Fatal(err)
	}
}
