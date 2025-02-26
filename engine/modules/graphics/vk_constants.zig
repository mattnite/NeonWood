const std = @import("std");
const vk = @import("vulkan");
const c = @import("c.zig");
const core = @import("../core.zig");

pub const MAX_OBJECTS = 100000;
pub const NUM_FRAMES: usize = 2;
pub const DEVICE_LAYERS = [_]core.CStr{VK_KHRONOS_VALIDATION_LAYER_STRING};

pub const required_device_layers = [_]core.CStr{"VK_LAYER_KHRONOS_validation"};

pub const VK_KHRONOS_VALIDATION_LAYER_STRING: core.CStr = "VK_LAYER_KHRONOS_validation";

pub const BaseDispatch = vk.BaseWrapper(.{
    .createInstance = true,
    .getInstanceProcAddr = true,
    .enumerateInstanceVersion = true,
    .enumerateInstanceLayerProperties = true,
    .enumerateInstanceExtensionProperties = true,
});

pub const InstanceDispatch = vk.InstanceWrapper(.{
    .getPhysicalDeviceFeatures = true,
    .destroyInstance = true,
    .createDevice = true,
    .destroySurfaceKHR = true,
    .enumeratePhysicalDevices = true,
    .getPhysicalDeviceProperties = true,
    .enumerateDeviceExtensionProperties = true,
    .getPhysicalDeviceSurfaceFormatsKHR = true,
    .getPhysicalDeviceSurfacePresentModesKHR = true,
    .getPhysicalDeviceSurfaceCapabilitiesKHR = true,
    .getPhysicalDeviceQueueFamilyProperties = true,
    .getPhysicalDeviceSurfaceSupportKHR = true,
    .getPhysicalDeviceMemoryProperties = true,
    .getPhysicalDeviceFormatProperties = true,
    .getDeviceProcAddr = true,
});

pub const DeviceDispatch = vk.DeviceWrapper(.{
    .resetCommandBuffer = true,
    .destroyDevice = true,
    .getDeviceQueue = true,
    .createSemaphore = true,
    .createFence = true,
    .createImageView = true,
    .createImage = true,
    .destroyImage = true,
    .destroyImageView = true,
    .destroySemaphore = true,
    .destroyFence = true,
    .getSwapchainImagesKHR = true,
    .createSwapchainKHR = true,
    .destroySwapchainKHR = true,
    .acquireNextImageKHR = true,
    .deviceWaitIdle = true,
    .waitForFences = true,
    .resetFences = true,
    .queueSubmit = true,
    .queuePresentKHR = true,
    .createCommandPool = true,
    .destroyCommandPool = true,
    .allocateCommandBuffers = true,
    .cmdBlitImage = true,
    .freeCommandBuffers = true,
    .queueWaitIdle = true,
    .createShaderModule = true,
    .destroyShaderModule = true,
    .createPipelineLayout = true,
    .destroyPipelineLayout = true,
    .createDescriptorSetLayout = true,
    .destroyDescriptorSetLayout = true,
    .createDescriptorPool = true,
    .allocateDescriptorSets = true,
    .updateDescriptorSets = true,
    .destroyDescriptorPool = true,
    .createRenderPass = true,
    .destroyRenderPass = true,
    .createGraphicsPipelines = true,
    .destroyPipeline = true,
    .createFramebuffer = true,
    .destroyFramebuffer = true,
    .beginCommandBuffer = true,
    .endCommandBuffer = true,
    .allocateMemory = true,
    .freeMemory = true,
    .createBuffer = true,
    .destroyBuffer = true,
    .getBufferMemoryRequirements = true,
    .mapMemory = true,
    .unmapMemory = true,
    .bindBufferMemory = true,
    .cmdBeginRenderPass = true,
    .cmdEndRenderPass = true,
    .cmdBindPipeline = true,
    .cmdBindIndexBuffer = true,
    .cmdDrawIndexed = true,
    .cmdDraw = true,
    .cmdSetViewport = true,
    .cmdSetScissor = true,
    .cmdBindVertexBuffers = true,
    .cmdCopyBuffer = true,
    .cmdPushConstants = true,
    .cmdPipelineBarrier = true,
    .cmdBindDescriptorSets = true,
    .cmdCopyBufferToImage = true,
    .createSampler = true,
    .destroySampler = true,
});
