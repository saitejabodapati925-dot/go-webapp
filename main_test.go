package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHomeRoute(t *testing.T) {
	req, err := http.NewRequest(http.MethodGet, "/home", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	newMux().ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	expected := "text/html; charset=utf-8"
	if contentType := rr.Header().Get("Content-Type"); contentType != expected {
		t.Errorf("handler returned unexpected content type: got %v want %v",
			contentType, expected)
	}
}

func TestRootRedirect(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	rr := httptest.NewRecorder()

	newMux().ServeHTTP(rr, req)

	if rr.Code != http.StatusFound {
		t.Fatalf("expected redirect status %d, got %d", http.StatusFound, rr.Code)
	}

	if location := rr.Header().Get("Location"); location != "/home" {
		t.Fatalf("expected redirect to /home, got %q", location)
	}
}

func TestStaticAssetRoute(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/static/styles.css", nil)
	rr := httptest.NewRecorder()

	newMux().ServeHTTP(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("expected status %d, got %d", http.StatusOK, rr.Code)
	}

	if contentType := rr.Header().Get("Content-Type"); !strings.HasPrefix(contentType, "text/css") {
		t.Fatalf("expected css content type, got %q", contentType)
	}
}
