export default function() {
  this.route("enhanced-ignore", function() {
    this.route("actions", function() {
      this.route("show", { path: "/:id" });
    });
  });
};
