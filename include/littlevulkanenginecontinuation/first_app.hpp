// See LICENSE file at the root of LittleVulkanEngineContinuation project

#pragma once

#include <CatVector/vector.hpp>
// std
#include <memory>

namespace lve {
class FirstApp {
 public:
  FirstApp();
  ~FirstApp();

  FirstApp(const FirstApp&) = delete;
  FirstApp& operator=(const FirstApp&) = delete;

  void run();

  static constexpr int s_WIDTH = 800;
  static constexpr int s_HEIGHT = 600;

 private:
};
}  // namespace lve
