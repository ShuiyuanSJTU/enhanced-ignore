import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("enhanced-ignore", { loggedIn: true });

test("enhanced-ignore works", async assert => {
  await visit("/admin/plugins/enhanced-ignore");

  assert.ok(false, "it shows the enhanced-ignore button");
});
