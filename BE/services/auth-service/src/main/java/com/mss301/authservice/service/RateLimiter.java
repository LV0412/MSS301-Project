package com.mss301.authservice.service;

public interface RateLimiter {

    void check(String bucket, String key, int limit);
}
