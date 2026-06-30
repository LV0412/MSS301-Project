package com.mss301.authservice.service;

import com.mss301.authservice.config.RateLimitProperties;
import com.mss301.authservice.exception.AuthException;
import com.mss301.authservice.exception.ErrorCode;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class InMemoryRateLimiter implements RateLimiter {

    private final RateLimitProperties rateLimitProperties;
    private final Map<String, WindowCounter> counters = new ConcurrentHashMap<>();

    public InMemoryRateLimiter(RateLimitProperties rateLimitProperties) {
        this.rateLimitProperties = rateLimitProperties;
    }

    @Override
    public void check(String bucket, String key, int limit) {
        String counterKey = bucket + ":" + normalizeKey(key);
        long now = Instant.now().getEpochSecond();
        long windowSeconds = rateLimitProperties.getWindowSeconds();

        WindowCounter counter = counters.compute(counterKey, (ignored, existing) -> {
            if (existing == null || now >= existing.windowStartedAt() + windowSeconds) {
                return new WindowCounter(now, 1);
            }
            return new WindowCounter(existing.windowStartedAt(), existing.count() + 1);
        });

        if (counter.count() > limit) {
            throw new AuthException(
                    ErrorCode.RATE_LIMIT_EXCEEDED,
                    "Too many requests. Please try again later.",
                    HttpStatus.TOO_MANY_REQUESTS);
        }
    }

    private String normalizeKey(String key) {
        return key == null ? "unknown" : key.trim().toLowerCase();
    }

    private record WindowCounter(long windowStartedAt, int count) {
    }
}
