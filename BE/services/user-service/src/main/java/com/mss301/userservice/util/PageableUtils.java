package com.mss301.userservice.util;

import java.util.List;
import java.util.Objects;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.util.StringUtils;

public final class PageableUtils {

    private PageableUtils() {
    }

    public static Pageable normalizeSort(Pageable pageable, String defaultSortProperty) {
        List<Sort.Order> validOrders = pageable.getSort().stream()
                .map(PageableUtils::cleanOrder)
                .filter(Objects::nonNull)
                .toList();

        Sort sort = validOrders.isEmpty()
                ? Sort.by(defaultSortProperty)
                : Sort.by(validOrders);

        return PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(), sort);
    }

    private static String cleanProperty(String property) {
        if (property == null) {
            return null;
        }
        return property.replace("[", "")
                .replace("]", "")
                .replace("\"", "")
                .trim();
    }

    private static Sort.Order cleanOrder(Sort.Order order) {
        String property = cleanProperty(order.getProperty());
        if (!StringUtils.hasText(property)) {
            return null;
        }
        return order.withProperty(property);
    }
}
