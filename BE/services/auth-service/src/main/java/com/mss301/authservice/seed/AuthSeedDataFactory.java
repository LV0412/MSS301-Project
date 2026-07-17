package com.mss301.authservice.seed;

import java.util.List;

public final class AuthSeedDataFactory {

    public static final String TEST_PASSWORD = "Password@123";

    private AuthSeedDataFactory() {
    }

    public static List<SeedAccount> accounts() {
        return List.of(
                account("minh.nguyen.seed@example.com", "Nguyen Minh"),
                account("linh.tran.seed@example.com", "Tran Linh"),
                account("quang.le.seed@example.com", "Le Quang"),
                account("mai.pham.seed@example.com", "Pham Mai"),
                account("huyen.vo.seed@example.com", "Vo Huyen"),
                account("bao.do.seed@example.com", "Do Bao"),
                account("an.ngo.seed@example.com", "Ngo An"),
                account("khoa.bui.seed@example.com", "Bui Khoa"),
                account("thao.dang.seed@example.com", "Dang Thao"),
                account("son.ho.seed@example.com", "Ho Son"));
    }

    private static SeedAccount account(String email, String fullName) {
        return new SeedAccount(email, fullName);
    }

    public record SeedAccount(
            String email,
            String fullName) {
    }
}
