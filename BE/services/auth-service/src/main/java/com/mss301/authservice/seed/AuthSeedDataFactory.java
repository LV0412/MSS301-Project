package com.mss301.authservice.seed;

import com.mss301.authservice.entity.AccountRole;
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
                account("son.ho.seed@example.com", "Ho Son"),
                account("admin2.seed@example.com", "Seed Admin Two", AccountRole.ADMIN));
    }

    private static SeedAccount account(String email, String fullName) {
        return account(email, fullName, AccountRole.USER);
    }

    private static SeedAccount account(String email, String fullName, AccountRole role) {
        return new SeedAccount(email, fullName, role);
    }

    public record SeedAccount(
            String email,
            String fullName,
            AccountRole role) {
    }
}
