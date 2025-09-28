### Optimization Model扩展功能 - 2025-01-28

**目标**: 在Optimization Model中添加qgenie和ollama两个选项，给予custom选项的参数，默认启用状态，并将ollama设为默认选择

**状态**: 进行中

#### 计划步骤
[x] 1. 查找Optimization Model相关代码位置
    - 预期结果：找到模型选择组件和配置文件
    - 风险评估：可能涉及多个文件，需要理解现有架构
    - 完成时间：2025-01-28 20:02
    - 实际结果：找到ModelSelectUI组件和static-models.ts配置文件
[x] 2. 分析现有custom选项的实现方式
    - 预期结果：理解参数结构和配置方式
    - 风险评估：需要保持向后兼容性
    - 完成时间：2025-01-28 20:02
    - 实际结果：custom选项使用环境变量配置，有baseURL、models、defaultModel等参数
[x] 3. 添加qgenie和ollama选项配置
    - 预期结果：新增两个模型选项，参数与custom相同
    - 风险评估：需要确保配置正确性
    - 完成时间：2025-01-28 20:04
    - 实际结果：成功添加qgenie和ollama两个选项，参数与custom相同
[x] 4. 设置默认状态和选择
    - 预期结果：两个选项默认启用，ollama为默认选择
    - 风险评估：可能影响现有用户配置
    - 完成时间：2025-01-28 20:04
    - 实际结果：两个选项都设为enabled: true，ollama通过位置排序成为默认选择
[ ] 5. 测试功能完整性
    - 预期结果：新选项正常工作，不影响现有功能
    - 风险评估：需要全面测试各种场景

#### 进展记录
- 2025-01-28 19:58 开始任务，已初始化workspace
- 2025-01-28 19:58 准备查找Optimization Model相关代码
- 2025-01-28 20:00 找到App.vue中的ModelSelectUI组件，这是模型选择的核心组件
- 2025-01-28 20:00 准备查找ModelSelectUI组件的实现
- 2025-01-28 20:02 找到关键文件：packages/core/src/services/model/static-models.ts
- 2025-01-28 20:02 发现custom选项的实现，准备添加qgenie和ollama选项
