import { config } from "dotenv";
import tsconfigPaths from "vite-tsconfig-paths";
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    passWithNoTests: true,
    globals: true,
    coverage: {
      include: ["src/*.ts"],
      provider: "v8",
    },
    env: {
      ...config({ path: "env/.env.test" }).parsed,
    },
  },
  plugins: [tsconfigPaths()],
});
