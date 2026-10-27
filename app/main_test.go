package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestRoutes(t *testing.T) {
	srv := httptest.NewServer(newMux(appInfo{Version: "abc123", Environment: "test"}))
	defer srv.Close()

	tests := []struct {
		name       string
		method     string
		path       string
		wantStatus int
		wantBody   string
	}{
		{"root", http.MethodGet, "/", http.StatusOK, `"message":"Hello from ECS Fargate"`},
		{"health", http.MethodGet, "/healthz", http.StatusOK, `"status":"ok"`},
		{"version", http.MethodGet, "/version", http.StatusOK, `"version":"abc123"`},
		{"unknown path", http.MethodGet, "/nope", http.StatusNotFound, ""},
		{"wrong method", http.MethodPost, "/healthz", http.StatusMethodNotAllowed, ""},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, _ := http.NewRequest(tt.method, srv.URL+tt.path, nil)
			resp, err := http.DefaultClient.Do(req)
			if err != nil {
				t.Fatal(err)
			}
			defer resp.Body.Close()

			if resp.StatusCode != tt.wantStatus {
				t.Fatalf("status = %d, want %d", resp.StatusCode, tt.wantStatus)
			}
			if tt.wantBody == "" {
				return
			}
			var body map[string]any
			if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
				t.Fatalf("decode body: %v", err)
			}
			raw, _ := json.Marshal(body)
			if !strings.Contains(string(raw), tt.wantBody) {
				t.Errorf("body = %s, want it to contain %s", raw, tt.wantBody)
			}
		})
	}
}

func TestProbe(t *testing.T) {
	healthy := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {}))
	defer healthy.Close()
	if code := probe(healthy.URL); code != 0 {
		t.Errorf("probe(healthy) = %d, want 0", code)
	}

	failing := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusServiceUnavailable)
	}))
	defer failing.Close()
	if code := probe(failing.URL); code != 1 {
		t.Errorf("probe(failing) = %d, want 1", code)
	}

	if code := probe("http://127.0.0.1:1/healthz"); code != 1 {
		t.Errorf("probe(unreachable) = %d, want 1", code)
	}
}

func TestLogRequestsKeepsStatus(t *testing.T) {
	h := logRequests(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusTeapot)
	}))
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/", nil))
	if rec.Code != http.StatusTeapot {
		t.Errorf("status = %d, want %d", rec.Code, http.StatusTeapot)
	}
}
