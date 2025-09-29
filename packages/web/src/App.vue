<template>
    <NConfigProvider :theme="naiveTheme" :theme-overrides="themeOverrides" :hljs="hljsInstance">
      <div v-if="isInitializing" class="loading-container">
        <div class="spinner"></div>
        <p>{{ t('log.info.initializing') }}</p>
      </div>
      <div v-else-if="!services" class="loading-container error">
        <p>{{ t('toast.error.appInitFailed') }}</p>
      </div>
      <template v-if="isReady">
        <MainLayoutUI>
          <!-- Title Slot -->
          <template #title>
            {{ $t('promptOptimizer.title') }}
          </template>

          <!-- Core Navigation Slot -->
          <template #core-nav>
            <FunctionModeSelector
              v-model="functionMode"
              @change="handleModeSelect"
            />
          </template>

          <!-- Actions Slot -->
          <template #actions>
          <!-- 核心功能区 -->
          <!-- 变量管理按钮 - 仅在高级模式下显示，放在高级模式按钮前确保布局稳定 -->
          <ActionButtonUI
            v-show="advancedModeEnabled"
            icon="📊"
            :text="$t('nav.variableManager')"
            @click="openVariableManager"
            type="default"
            size="medium"
            :ghost="false"
            :round="true"
          />
          <ActionButtonUI
            icon="📝"
            :text="$t('nav.templates')"
            @click="openTemplateManager"
            type="default"
            size="medium"
            :ghost="false"
            :round="true"
          />
          <ActionButtonUI
            icon="📜"
            :text="$t('nav.history')"
            @click="historyManager.showHistory = true"
            type="default"
            size="medium"
            :ghost="false"
            :round="true"
          />
          <ActionButtonUI
            icon="⚙️"
            :text="$t('nav.modelManager')"
            @click="modelManager.showConfig = true"
            type="default"
            size="medium"
            :ghost="false"
            :round="true"
          />
          <ActionButtonUI
            icon="💾"
            :text="$t('nav.dataManager')"
            @click="showDataManager = true"
            type="default"
            size="medium"
            :ghost="false"
            :round="true"
          />
          
          <!-- 辅助功能区 - 使用简化样式降低视觉权重 -->
          <ThemeToggleUI />
          <ActionButtonUI
            icon=""
            text=""
            @click="openGithubRepo"
            size="small"
            type="quaternary"
            :ghost="true"
          >
            <template #icon>
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 0C5.374 0 0 5.373 0 12 0 17.302 3.438 21.8 8.207 23.387c.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0112 5.803c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576C20.566 21.797 24 17.3 24 12c0-6.627-5.373-12-12-12z"/>
              </svg>
            </template>
          </ActionButtonUI>
          <LanguageSwitchDropdown />
          <!-- 自动更新组件 - 仅在Electron环境中显示 -->
          <UpdaterIcon />
          </template>
        <template #main>
  
          
        <!-- 非图像模式：沿用现有布局 -->
        <template v-if="functionMode !== 'image'">
        <!-- Main Content - 使用 Naive UI NGrid 实现响应式水平左右布局 class="h-full min-h-0 overflow-hidden max-height=100%" -->
        <NFlex  justify="space-between" :style="{display: 'flex',  flexDirection: 'row', width: '100%' , 'max-height': '100%', gap: '16px' }" >
          <!-- 左侧：优化区域 -->
          <NFlex vertical :style="{ flex: 1, overflow: 'auto', height: '100%' }">
            <!-- 组件 A: InputPanelUI -->
            <NCard :style="{ flexShrink: 0, minHeight: '200px' }">
              <InputPanelUI
                v-model="optimizer.prompt"
                v-model:selectedModel="modelManager.selectedOptimizeModel"
                :label="promptInputLabel"
                :placeholder="promptInputPlaceholder"
                :model-label="$t('promptOptimizer.optimizeModel')"
                :template-label="$t('promptOptimizer.templateLabel')"
                :button-text="$t('promptOptimizer.optimize')"
                :loading-text="$t('common.loading')"
                :loading="optimizer.isOptimizing"
                :disabled="optimizer.isOptimizing"
                @submit="handleOptimizePrompt"
                @configModel="modelManager.showConfig = true"
              >
                <template #optimization-mode-selector>
                  <OptimizationModeSelectorUI
                    v-model="selectedOptimizationMode"
                    @change="handleOptimizationModeChange"
                  />
                </template>
                <template #model-select>
                  <ModelSelectUI
                    :ref="(el) => modelSelectRefs.optimizeModelSelect = el"
                    :modelValue="modelManager.selectedOptimizeModel"
                    @update:modelValue="modelManager.selectedOptimizeModel = $event"
                    :disabled="optimizer.isOptimizing"
                    @config="modelManager.showConfig = true"
                  />
                </template>
                <template #template-select>
                  <TemplateSelectUI
                    v-if="services && services.templateManager"
                    ref="templateSelectRef"
                    v-model="currentSelectedTemplate"
                    :type="templateSelectType"
                    :optimization-mode="selectedOptimizationMode"
                    @manage="openTemplateManager"
                  />
                  <NText v-else depth="3" class="p-2 text-sm">
                    {{ t('template.loading') || '加载中...' }}
                  </NText>
                </template>
              </InputPanelUI>
            </NCard>
            
            <!-- 组件 B: ConversationManager (使用v-show替代v-if避免组件频繁销毁重建) -->
            <NCard v-show="advancedModeEnabled" :style="{ flexShrink: 0, minHeight: '150px', overflow: 'auto' }" content-style="padding: 0;">
              <ConversationManager
                v-model:messages="optimizationContext"
                :available-variables="variableManager?.variableManager.value?.resolveAllVariables() || {}"
                :scan-variables="(content) => variableManager?.variableManager.value?.scanVariablesInContent(content) || []"
                :optimization-mode="selectedOptimizationMode"
                :tool-count="optimizationContextTools.length"
                @open-variable-manager="handleOpenVariableManager"
                @open-context-editor="handleOpenContextEditor"
                :collapsible="true"
                :max-height="300"
              />
            </NCard>
            
            <!-- 组件 C: PromptPanelUI -->
            <NCard :style="{ flex: 1, minHeight: '200px', overflow: 'hidden' }"
            content-style="height: 100%; max-height: 100%; overflow: hidden;"
            >
              <PromptPanelUI
                v-if="services && services.templateManager"
                ref="promptPanelRef"
                v-model:optimized-prompt="optimizer.optimizedPrompt"
                :reasoning="optimizer.optimizedReasoning"
                :original-prompt="optimizer.prompt"
                :is-optimizing="optimizer.isOptimizing"
                :is-iterating="optimizer.isIterating"
                v-model:selected-iterate-template="optimizer.selectedIterateTemplate"
                :versions="optimizer.currentVersions"
                :current-version-id="optimizer.currentVersionId"
                :optimization-mode="selectedOptimizationMode"
                :services="services"
                :advanced-mode-enabled="advancedModeEnabled"
                @iterate="handleIteratePrompt"
                @openTemplateManager="openTemplateManager"
                @switchVersion="handleSwitchVersion"
              />
            </NCard>
          </NFlex>
  
          <!-- 右侧：测试区域 -->
          <NCard :style="{ flex: 1, overflow: 'auto', height: '100%' }"
            content-style="height: 100%; max-height: 100%; overflow: hidden;"
          >
            <!-- 使用新的统一TestAreaPanel组件 -->
            <TestAreaPanel
              ref="testPanelRef"
              :optimization-mode="selectedOptimizationMode"
              :is-test-running="false"
              :advanced-mode-enabled="advancedModeEnabled"
              v-model:test-content="testContent"
              v-model:is-compare-mode="isCompareMode"
              :enable-compare-mode="true"
              :enable-fullscreen="true"
              :input-mode="responsiveLayout.recommendedInputMode.value"
              :control-bar-layout="responsiveLayout.recommendedControlBarLayout.value" 
              :button-size="responsiveLayout.smartButtonSize.value"
              :conversation-max-height="responsiveLayout.responsiveHeights.value.conversationMax"
              :show-original-result="true"
              :result-vertical-layout="responsiveLayout.isMobile.value"
              @test="handleTestAreaTest"
              @compare-toggle="handleTestAreaCompareToggle"
            >
              <!-- 模型选择插槽 -->
              <template #model-select>
                <ModelSelectUI
                  :ref="(el) => modelSelectRefs.testModelSelect = el"
                  :modelValue="modelManager.selectedTestModel"
                  @update:modelValue="modelManager.selectedTestModel = $event"
                  :disabled="false"
                  @config="modelManager.showConfig = true"
                />
              </template>
    
              <!-- 原始结果插槽 -->
              <template #original-result>
                <OutputDisplay
                  :content="testResults.originalResult"
                  :reasoning="testResults.originalReasoning"
                  :streaming="testResults.isTestingOriginal"
                  :enableDiff="false"
                  mode="readonly"
                  :style="{ height: '100%', minHeight: '0' }"
                />
              </template>
  
              <!-- 优化结果插槽 -->  
              <template #optimized-result>
                <OutputDisplay
                  :content="testResults.optimizedResult"
                  :reasoning="testResults.optimizedReasoning"
                  :streaming="testResults.isTestingOptimized"
                  :enableDiff="false"
                  mode="readonly"
                  :style="{ height: '100%', minHeight: '0' }"
                />
              </template>
  
              <!-- 单一结果插槽 -->
              <template #single-result>
                <OutputDisplay
                  :content="testResults.optimizedResult"
                  :reasoning="testResults.optimizedReasoning"
                  :streaming="testResults.isTestingOptimized"
                  :enableDiff="false"
                  mode="readonly"
                  :style="{ height: '100%', minHeight: '0' }"
                />
              </template>
            </TestAreaPanel>
          </NCard>
        </NFlex>
        </template>
        <!-- 图像模式：渲染新的工作区组件，不破坏现有结构 -->
        <template v-else>
          <ImageWorkspace />
        </template>
        </template>
      </MainLayoutUI>
  
      <!-- Modals and Drawers that are conditionally rendered -->
      <ModelManagerUI
        v-if="isReady"
        v-model:show="modelManager.showConfig"
        @update:show="(v: boolean) => { if (!v) handleModelManagerClosed() }"
      />
      <TemplateManagerUI
        v-if="isReady"
        v-model:show="templateManagerState.showTemplates"
        :templateType="templateManagerState.currentType"
        @close="() => templateManagerState.handleTemplateManagerClose(() => templateSelectRef?.refresh?.())"
        @languageChanged="handleTemplateLanguageChanged"
      />
      <HistoryDrawerUI
        v-if="isReady"
        v-model:show="historyManager.showHistory"
        :history="promptHistory.history"
        @reuse="handleHistoryReuse"
        @clear="promptHistory.handleClearHistory"
        @deleteChain="promptHistory.handleDeleteChain"
      />
      <DataManagerUI v-if="isReady" v-model:show="showDataManager" @imported="handleDataImported" />
      
      <!-- 变量管理弹窗 -->
      <VariableManagerModal
        v-if="isReady"
        v-model:visible="showVariableManager"
        :variable-manager="variableManager"
        :focus-variable="focusVariableName"
      />

      <!-- 上下文编辑器弹窗 -->
      <ContextEditor
        v-if="isReady"
        v-model:visible="showContextEditor"
        :state="contextEditorState"
        :available-variables="variableManager?.allVariables.value || {}"
        :optimization-mode="selectedOptimizationMode"
        :scan-variables="(content) => variableManager?.variableManager.value?.scanVariablesInContent(content) || []"
        :replace-variables="(content, vars) => variableManager?.variableManager.value?.replaceVariables(content, vars) || content"
        title="上下文编辑器"
        @update:state="handleContextEditorStateUpdate"
        @save="handleContextEditorSave"
        @cancel="showContextEditor = false"
        @open-variable-manager="handleOpenVariableManager"
      />
  
      <!-- 关键：使用NGlobalStyle同步全局样式到body，消除CSS依赖 -->
      <NGlobalStyle />
  
      <!-- ToastUI已在MainLayoutUI中包含，无需重复渲染 -->
      </template>
    </NConfigProvider>
  </template>
  
  <script setup lang="ts">
  import { ref, watch, provide, computed, shallowRef, toRef, nextTick, onMounted } from 'vue'
  import { useI18n } from 'vue-i18n'
  import { NConfigProvider, NGlobalStyle, NButton, NText, NGrid, NGridItem, NCard, NFlex, useMessage } from 'naive-ui'
import hljs from 'highlight.js/lib/core'
import jsonLang from 'highlight.js/lib/languages/json'
hljs.registerLanguage('json', jsonLang)
  import {
    // UI Components
    MainLayoutUI, ThemeToggleUI, ActionButtonUI, ModelManagerUI, TemplateManagerUI, HistoryDrawerUI,
    LanguageSwitchDropdown, DataManagerUI, InputPanelUI, PromptPanelUI, OptimizationModeSelectorUI,
    ModelSelectUI, TemplateSelectUI, TestAreaPanel, UpdaterIcon, VariableManagerModal,
    ImageWorkspace, FunctionModeSelector,
    ConversationManager, OutputDisplay, ContextEditor,
  
    // Composables
    usePromptOptimizer,
    useToast,
    useHistoryManager,
    useModelManager,
    useTemplateManager,
    useAppInitializer,
    usePromptHistory,
    useModelSelectRefs,
    useVariableManager,
    useNaiveTheme,
    useResponsiveTestLayout,
    useTestModeConfig,
    useFunctionMode,
  
    // i18n functions
    initializeI18nWithStorage,
    setI18nServices,
  
    // Types from UI package
    type OptimizationMode,
    type ConversationMessage,
    
    // Quick Template Manager
    quickTemplateManager,
  } from '@prompt-optimizer/ui'
  import type { IPromptService } from '@prompt-optimizer/core'
  
  // 1. 基础 composables
  // highlight.js for Naive NCode
  const hljsInstance = hljs
  const { t } = useI18n()
  // 移除全局toast实例，改为在需要时本地调用
  
  // 2. 初始化应用服务
  const { services, isInitializing } = useAppInitializer()
  
  // 3. Initialize i18n with storage when services are ready
  watch(services, async (newServices) => {
    if (newServices) {
      // 首先设置服务引用
      setI18nServices(newServices)
      // 然后初始化语言设置
      await initializeI18nWithStorage()
      console.log('[Web] i18n initialized')
      
  // 移除：高级模式设置的独立加载（改为 useFunctionMode 管理）
    }
  }, { immediate: true })
  
  // 4. 向子组件提供服务
  provide('services', services)
  
  // 5. 控制主UI渲染的标志
  const isReady = computed(() => !!services.value && !isInitializing.value)
  
  // 6. 创建所有必要的引用
  const promptService = shallowRef<IPromptService | null>(null)
  const selectedOptimizationMode = ref<OptimizationMode>('user')
  const showDataManager = ref(false)
  const optimizeModelSelect = ref(null)
  const testPanelRef = ref(null)
  const templateSelectRef = ref<{ refresh?: () => void } | null>(null)
  const promptPanelRef = ref<{ refreshIterateTemplateSelect?: () => void } | null>(null)
  
  // 高级模式状态
  const { functionMode, setFunctionMode } = useFunctionMode(services as any)
  const advancedModeEnabled = computed({
    get: () => functionMode.value === 'pro',
    set: (val: boolean) => { setFunctionMode(val ? 'pro' : 'basic') }
  })

  // 处理功能模式变化
  const handleModeSelect = async (mode: 'basic' | 'pro' | 'image') => {
    await setFunctionMode(mode)
  }

  // 测试内容状态 - 新增
  const testContent = ref('')
  const isCompareMode = ref(true)
  
  // 测试结果状态管理
  const testResults = ref({
    // 原始提示词结果
    originalResult: '',
    originalReasoning: '',
    isTestingOriginal: false,
    
    // 优化提示词结果
    optimizedResult: '',
    optimizedReasoning: '',
    isTestingOptimized: false,
    
    // 单一结果模式
    singleResult: '',
    singleReasoning: '',
    isTestingSingle: false
  })
  
  // 响应式布局和模式配置 - 新增
  const responsiveLayout = useResponsiveTestLayout()
  const testModeConfig = useTestModeConfig(selectedOptimizationMode)
  
  // Naive UI 主题配置 - 使用新的主题系统
  const { naiveTheme, themeOverrides, initTheme } = useNaiveTheme()
  
  // 初始化主题系统
  if (typeof window !== 'undefined') {
    initTheme()
  }
  
  // 取消独立的高级模式偏好读写，改由 useFunctionMode 统一管理（默认 basic）
  
  // 变量管理状态
  const showVariableManager = ref(false)
  const focusVariableName = ref<string | undefined>(undefined)
  
  // 上下文编辑器状态
  const showContextEditor = ref(false)
  const contextEditorState = ref({
    messages: [] as ConversationMessage[],
    variables: {} as Record<string, string>,
    tools: [] as any[],
    showVariablePreview: true,
    showToolManager: false,
    mode: 'edit' as 'edit' | 'preview'
  })
  
  // 优化阶段上下文状态
  const optimizationContext = ref<ConversationMessage[]>([])
  const optimizationContextTools = ref<any[]>([])  // 🆕 添加工具状态
  // 标记是否已从持久化仓库加载过上下文（用于区分 null vs [] 语义）
  const isContextLoaded = ref(false)
  
  // 变量管理器实例
  const variableManager = useVariableManager(services as any)
  
  // 上下文持久化状态
  const currentContextId = ref<string | null>(null)
  const contextRepo = computed(() => services.value?.contextRepo)
  
  // 初始化上下文持久化
  const initializeContextPersistence = async () => {
    if (!contextRepo.value) return
    
    try {
      // 获取当前上下文ID
      currentContextId.value = await contextRepo.value.getCurrentId()
      
      if (currentContextId.value) {
        // 加载当前上下文
        const context = await contextRepo.value.get(currentContextId.value)
        if (context) {
          optimizationContext.value = [...context.messages]
          optimizationContextTools.value = [...(context.tools || [])]
          
          // 🚫 移除全局变量同步 - 上下文变量不应污染全局变量库
          // 上下文变量应该只存在于上下文中，通过上下文编辑器进行管理
          // 这里只需要加载消息和工具，变量在上下文编辑器中自动获取
        }
      }
    } catch (error) {
      console.warn('[App] Failed to initialize context persistence:', error)
    } finally {
      // 无论成功失败，都认为已完成一次初始化尝试
      isContextLoaded.value = true
    }
  }
  
  // 持久化上下文更新（轻度节流）
  let persistContextUpdateTimer: NodeJS.Timeout | null = null
  const persistContextUpdate = async (patch: {
    messages?: ConversationMessage[]
    variables?: Record<string, string>
    tools?: any[]
  }) => {
    if (!contextRepo.value || !currentContextId.value) return
    
    // 清除之前的定时器
    if (persistContextUpdateTimer) {
      clearTimeout(persistContextUpdateTimer)
    }
    
    // 设置新的节流定时器（300ms延迟）
    persistContextUpdateTimer = setTimeout(async () => {
      try {
        await contextRepo.value!.update(currentContextId.value!, patch)
        console.log('[App] Context persisted to storage')
      } catch (error) {
        console.warn('[App] Failed to persist context update:', error)
      }
    }, 300)
  }
  
  const templateSelectType = computed<'optimize' | 'userOptimize' | 'iterate' | 'contextSystemOptimize' | 'contextUserOptimize'>(() => {
    const isPro = advancedModeEnabled.value
    if (selectedOptimizationMode.value === 'system') {
      return isPro ? 'contextSystemOptimize' : 'optimize'
    }
    return isPro ? 'contextUserOptimize' : 'userOptimize'
  })
  
  // 变量管理处理函数
  const handleCreateVariable = (name: string, defaultValue?: string) => {
    // 创建新变量并打开变量管理器
    if (variableManager?.variableManager.value) {
      variableManager.variableManager.value.setVariable(name, defaultValue || '')
    }
    focusVariableName.value = name
    showVariableManager.value = true
  }
  
  const handleOpenVariableManager = (variableName?: string) => {
    // 打开变量管理器并聚焦到指定变量
    if (variableName) {
      focusVariableName.value = variableName
    }
    showVariableManager.value = true
  }
  
  // 打开上下文编辑器
  const handleOpenContextEditor = async (messages?: ConversationMessage[], variables?: Record<string, string>) => {
    // 确保全局变量已加载并刷新（避免初次为空）
    try {
      await variableManager?.refresh?.()
    } catch (e) {
      console.warn('[App] Variable manager refresh failed (non-blocking):', e)
    }
    // 若首次加载（未完成持久化加载）且高级模式开启且当前无会话消息，按模式灌入默认模板
    if (advancedModeEnabled.value && !isContextLoaded.value && (!optimizationContext.value || optimizationContext.value.length === 0)) {
      try {
        const defaultTemplate = quickTemplateManager.getTemplate(selectedOptimizationMode.value, 'default')
        if (defaultTemplate?.messages?.length) {
          optimizationContext.value = [...defaultTemplate.messages]
          console.log(`[App] Auto-filled default template for ${selectedOptimizationMode.value} on first open of ContextEditor`)
        }
      } catch (e) {
        console.warn('[App] Failed to auto-fill default template on editor open:', e)
      }
    }
    // 🔧 修复：从 contextRepo 读取真正的上下文变量，避免全局变量污染
    let contextVariables: Record<string, string> = {}
    
    if (contextRepo.value && currentContextId.value) {
      try {
        const context = await contextRepo.value.get(currentContextId.value)
        contextVariables = context?.variables || {}
        console.log('[App] Loaded context variables from contextRepo:', Object.keys(contextVariables))
      } catch (error) {
        console.warn('[App] Failed to load context variables:', error)
      }
    }
    
    // 设置初始状态 - 只使用上下文本身的变量
    contextEditorState.value = {
      messages: messages || [...optimizationContext.value],
      variables: contextVariables, // 🚫 不再使用传入的全局变量
      tools: [...optimizationContextTools.value],  // 🆕 传递现有工具状态
      showVariablePreview: true,
      showToolManager: false,
      mode: 'edit'
    }
    showContextEditor.value = true
  }
  
  // 处理上下文编辑器保存
  const handleContextEditorSave = async (context: { messages: ConversationMessage[], variables: Record<string, string>, tools: any[] }) => {
    // 更新优化上下文
    optimizationContext.value = [...context.messages]
    optimizationContextTools.value = [...context.tools]  // 🆕 保存工具状态
    
    // 🚫 移除全局变量更新 - 上下文变量不应污染全局变量库
    // 上下文变量应该只存在于上下文中，通过 persistContextUpdate 持久化到 contextRepo
    
    // 持久化到contextRepo
    await persistContextUpdate({
      messages: context.messages,
      variables: context.variables,
      tools: context.tools
    })
    
    // 关闭编辑器
    showContextEditor.value = false
    
    // 显示成功提示
    useToast().success('上下文已更新')
  }
  
  // 处理上下文编辑器实时状态更新
  const handleContextEditorStateUpdate = async (state: { messages: ConversationMessage[], variables: Record<string, string>, tools: any[] }) => {
    // 实时同步状态到contextEditorState
    contextEditorState.value = { ...contextEditorState.value, ...state }
    
    // 实时更新优化上下文（保持轻量级Manager的数据同步）
    optimizationContext.value = [...state.messages]
    optimizationContextTools.value = [...(state.tools || [])]  // 🆕 同步工具状态
    
    // 🚫 移除全局变量更新 - 上下文变量不应污染全局变量库
    // 上下文变量应该只存在于上下文中，通过 persistContextUpdate 持久化到 contextRepo
    
    // 实时持久化（节流处理在persistContextUpdate中处理）
    await persistContextUpdate({
      messages: state.messages,
      variables: state.variables,
      tools: state.tools
    })
    
    console.log('[App] Context editor state synchronized and persisted in real-time')
  }

  // 监听主界面上下文管理器（ConversationManager）的消息变更，自动持久化
  watch(optimizationContext, async (newMessages) => {
    // 避免与全屏编辑器重复持久化（全屏编辑器已有专属持久化逻辑）
    if (showContextEditor.value) return
    await persistContextUpdate({ messages: newMessages })
  }, { deep: true })
  
  // 6. 在顶层调用所有 Composables
  // 模型选择器引用管理
  const modelSelectRefs = useModelSelectRefs()
  
  // 使用类型断言解决类型不匹配问题
  // 模型管理器
  const modelManager = useModelManager(
    services as any,
    modelSelectRefs
  )
  
  // 提示词优化器
  const optimizer = usePromptOptimizer(
    services as any,
    selectedOptimizationMode,
    toRef(modelManager, 'selectedOptimizeModel'),
    toRef(modelManager, 'selectedTestModel')
  )
  
  // 提示词历史
  const promptHistory = usePromptHistory(
    services as any,
    toRef(optimizer, 'prompt') as any,
    toRef(optimizer, 'optimizedPrompt') as any,
    toRef(optimizer, 'currentChainId') as any,
    toRef(optimizer, 'currentVersions') as any,
    toRef(optimizer, 'currentVersionId') as any
  )

  // 提供全局历史实例给子组件复用
  provide('promptHistory', promptHistory)
  
  // 历史管理器
  const historyManager = useHistoryManager(
    services as any,
    optimizer.prompt as any,
    optimizer.optimizedPrompt as any,
    optimizer.currentChainId as any,
    optimizer.currentVersions as any,
    optimizer.currentVersionId as any,
    promptHistory.handleSelectHistory,
    promptHistory.handleClearHistory,
    promptHistory.handleDeleteChain as any
  )
  
  // 模板管理器
  const templateManagerState = useTemplateManager(
    services as any,
    {
      selectedOptimizeTemplate: toRef(optimizer, 'selectedOptimizeTemplate'),
      selectedUserOptimizeTemplate: toRef(optimizer, 'selectedUserOptimizeTemplate'),
      selectedIterateTemplate: toRef(optimizer, 'selectedIterateTemplate')
    }
  )
  
  // 7. 监听服务初始化
  watch(services, async (newServices) => {
    if (!newServices) return
  
    // 设置服务引用
    promptService.value = newServices.promptService
    
    // 初始化上下文持久化
    await initializeContextPersistence()

    // 确保功能模式已初始化（默认 basic）
    // useFunctionMode 内部已处理默认值与持久化
  
    console.log('All services and composables initialized.')

    // 监听全局历史刷新事件（来自图像模式）
    const handleGlobalHistoryRefresh = () => {
      promptHistory.initHistory()
    }
    window.addEventListener('prompt-optimizer:history-refresh', handleGlobalHistoryRefresh)
  })
  
  // 8. 处理数据导入成功后的刷新
  const handleDataImported = () => {
    console.log('[App] 数据导入成功，即将刷新页面以应用所有更改...')
  
    // 显示成功提示，然后刷新页面
    useToast().success(t('dataManager.import.successWithRefresh'))
  
    // 延迟一点时间让用户看到成功提示，然后刷新页面
    setTimeout(() => {
      window.location.reload()
    }, 1500)
  }
  
  // 8. 计算属性和方法
  const currentSelectedTemplate = computed({
    get() {
      return selectedOptimizationMode.value === 'system'
        ? optimizer.selectedOptimizeTemplate
        : optimizer.selectedUserOptimizeTemplate
    },
    set(newValue) {
      if (!newValue) return
      if (selectedOptimizationMode.value === 'system') {
        optimizer.selectedOptimizeTemplate = newValue
      } else {
        optimizer.selectedUserOptimizeTemplate = newValue
      }
    }
  })
  
  // 处理优化提示词
  const handleOptimizePrompt = () => {
    // 检查是否需要传递高级上下文
    if (advancedModeEnabled.value) {
      // 构建高级上下文
      const advancedContext = {
        variables: variableManager?.variableManager.value?.resolveAllVariables() || {},
        messages: optimizationContext.value.length > 0 ? optimizationContext.value : undefined,
        tools: optimizationContextTools.value.length > 0 ? optimizationContextTools.value : undefined  // 🆕 添加工具传递
      }
      
      console.log('[App] Optimizing with advanced context:', advancedContext)
      
      // 使用带上下文的优化
      optimizer.handleOptimizePromptWithContext(advancedContext)
    } else {
      // 使用基础优化
      optimizer.handleOptimizePrompt()
    }
  }
  
  // 处理迭代提示词
  const handleIteratePrompt = (payload: any) => {
    optimizer.handleIteratePrompt(payload)
  }
  
  // 处理切换版本
  const handleSwitchVersion = (versionId: any) => {
    optimizer.handleSwitchVersion(versionId)
  }
  
  // 处理高级模式变化
  const handleAdvancedModeChange = (enabled: boolean) => {
    advancedModeEnabled.value = enabled
    console.log(`[App] Advanced mode ${enabled ? 'enabled' : 'disabled'}`)
  }
  
  // 切换高级模式（导航菜单使用）
  const toggleAdvancedMode = async () => {
    const next = !advancedModeEnabled.value
    advancedModeEnabled.value = next
    console.log(`[App] Advanced mode ${next ? 'enabled' : 'disabled'} (toggled from navigation)`)
  }
  
  // 打开变量管理器
  const openVariableManager = (variableName?: string) => {
    // 强制刷新变量管理器数据
    if (variableManager?.refresh) {
      variableManager.refresh()
    }
    // 设置要聚焦的变量名
    focusVariableName.value = variableName
    showVariableManager.value = true
  }
  
  // 监听变量管理器关闭，清理聚焦变量
  watch(showVariableManager, (newValue) => {
    if (!newValue) {
      focusVariableName.value = undefined
    }
  })
  
  // 监听高级模式和优化模式变化，自动加载默认快速模板
  watch(
    [advancedModeEnabled, selectedOptimizationMode],
    ([newAdvancedMode, newOptimizationMode]) => {
      // 当启用高级模式时，根据优化模式自动加载默认快速模板
      if (newAdvancedMode) {
        // 如果当前没有优化上下文或者是空的，则设置默认模板
        if (!optimizationContext.value || optimizationContext.value.length === 0) {
          try {
            // 根据优化模式获取默认模板
            const defaultTemplate = quickTemplateManager.getTemplate(newOptimizationMode, 'default')
            
            if (defaultTemplate && defaultTemplate.messages) {
              optimizationContext.value = [...defaultTemplate.messages]
              console.log(`[App] Auto-loaded default ${newOptimizationMode} template: ${defaultTemplate.name}`)
            } else {
              // 如果获取模板失败，回退到硬编码逻辑
              console.warn(`[App] Failed to load default ${newOptimizationMode} template, using fallback`)
              if (newOptimizationMode === 'system') {
                optimizationContext.value = [
                  { role: 'system', content: '{{currentPrompt}}' },
                  { role: 'user', content: '{{userQuestion}}' }
                ]
              } else if (newOptimizationMode === 'user') {
                optimizationContext.value = [
                  { role: 'user', content: '{{currentPrompt}}' }
                ]
              }
            }
          } catch (error) {
            // 如果获取模板失败，回退到硬编码逻辑
            console.warn('[App] Failed to load default template, using fallback logic:', error)
            if (newOptimizationMode === 'system') {
              optimizationContext.value = [
                { role: 'system', content: '{{currentPrompt}}' },
                { role: 'user', content: '{{userQuestion}}' }
              ]
              console.log('[App] Auto-loaded fallback template for system prompt optimization')
            } else if (newOptimizationMode === 'user') {
              optimizationContext.value = [
                { role: 'user', content: '{{currentPrompt}}' }
              ]
              console.log('[App] Auto-loaded fallback template for user prompt optimization')
            }
          }
        }
      }
    },
    { immediate: false } // 不立即执行，只在变化时执行
  )
  
  // 打开GitHub仓库
  const openGithubRepo = async () => {
    const url = 'https://github.com/linshenkx/prompt-optimizer'
  
    // 检查是否在Electron环境中
    if (typeof window !== 'undefined' && (window as any).electronAPI) {
      try {
        await (window as any).electronAPI.shell.openExternal(url)
      } catch (error) {
        console.error('Failed to open external URL in Electron:', error)
        // 如果Electron API失败，回退到window.open
        window.open(url, '_blank')
      }
    } else {
      // Web环境中使用window.open
      window.open(url, '_blank')
    }
  }
  
  // 打开模板管理器
  const openTemplateManager = (templateType?: 'optimize' | 'userOptimize' | 'iterate' | 'text2imageOptimize' | 'image2imageOptimize' | 'imageIterate') => {
    // 如果传入了模板类型，直接使用；否则根据当前优化模式判断（向后兼容）
    templateManagerState.currentType = (templateType as any) || (selectedOptimizationMode.value === 'system' ? 'optimize' : 'userOptimize')
    templateManagerState.showTemplates = true
  }
  
  // 处理优化模式变更
  const handleOptimizationModeChange = (mode: OptimizationMode) => {
    selectedOptimizationMode.value = mode
  }
  
  // 处理模板语言变化
  const handleTemplateLanguageChanged = (newLanguage: string) => {
    console.log('[App] 模板语言已切换:', newLanguage)

    // 刷新主界面的模板选择组件
    if (templateSelectRef.value?.refresh) {
      templateSelectRef.value.refresh()
    }

    // 刷新迭代页面的模板选择组件
    if (promptPanelRef.value?.refreshIterateTemplateSelect) {
      promptPanelRef.value.refreshIterateTemplateSelect()
    }

    // 通知图像模式工作区刷新迭代模板选择
    if (typeof window !== 'undefined') {
      window.dispatchEvent(new Event('image-workspace-refresh-iterate-select'))
    }
  }

  // 向子组件提供统一的 openTemplateManager 接口（图像模式复用）
  provide('openTemplateManager', openTemplateManager)

  // 模型管理器关闭回调：同步刷新基础模式下拉，并通知图像模式刷新图像模型
  const handleModelManagerClosed = async () => {
    try {
      // 基础模式：复用现有逻辑刷新文本模型与下拉
      modelManager.handleModelManagerClose()
    } catch (e) {
      console.warn('[App] Failed to refresh text models after manager close:', e)
    }
    // 图像模式：广播刷新图像模型事件（ImageWorkspace 监听并执行刷新）
    if (typeof window !== 'undefined') {
      window.dispatchEvent(new Event('image-workspace-refresh-image-models'))
    }
  }
  
  // 处理历史记录使用 - 智能模式切换
  const handleHistoryReuse = async (context: { record: any, chainId: string, rootPrompt: string, chain: any }) => {
    const { record, chain } = context
    const rt = chain.rootRecord.type

    // 🆕 扩展模式切换逻辑 - 支持图像模式
    if (rt === 'imageOptimize' || rt === 'contextImageOptimize' || rt === 'imageIterate' ||
        rt === 'text2imageOptimize' || rt === 'image2imageOptimize') {
      // 切换到图像模式
      await setFunctionMode('image')
      useToast().info('已自动切换到图像模式')
      
      // 🆕 图像模式专用数据回填逻辑
      // 等待模式切换完成后再回填数据
      await nextTick()

      // 根据记录类型设置正确的图像子模式
      const imageMode = rt === 'text2imageOptimize' ? 'text2image' :
                       rt === 'image2imageOptimize' ? 'image2image' :
                       'text2image' // 默认为文生图模式

      // 通过全局事件或直接访问ImageWorkspace的数据来回填
      // 由于ImageWorkspace是独立组件，我们需要通过provide/inject或事件系统来传递数据
      const imageHistoryData = {
        originalPrompt: record.originalPrompt || chain.rootRecord.originalPrompt,
        optimizedPrompt: record.optimizedPrompt,
        metadata: record.metadata || chain.rootRecord.metadata,
        chainId: chain.chainId,
        versions: chain.versions,
        currentVersionId: record.id,
        imageMode: imageMode // 添加图像模式信息
      }
      
      // 触发图像工作区数据恢复事件
      if (typeof window !== 'undefined') {
        window.dispatchEvent(new CustomEvent('image-workspace-restore', {
          detail: imageHistoryData
        }))
      }
      
      useToast().success('图像历史记录已恢复')
      return // 图像模式不需要调用原有的历史记录处理逻辑
    } else {
      // 根据链条的根记录类型确定应该切换到的优化模式
      let targetMode: OptimizationMode
      if (rt === 'optimize' || rt === 'contextSystemOptimize') {
        targetMode = 'system'
      } else if (rt === 'userOptimize' || rt === 'contextUserOptimize') {
        targetMode = 'user'
      } else {
        // 兜底：从根记录的 metadata 中获取优化模式
        targetMode = chain.rootRecord.metadata?.optimizationMode || 'system'
      }

      // 如果目标模式与当前模式不同，自动切换
      if (targetMode !== selectedOptimizationMode.value) {
        selectedOptimizationMode.value = targetMode
        useToast().info(t('toast.info.optimizationModeAutoSwitched', {
          mode: targetMode === 'system' ? t('common.system') : t('common.user')
        }))
      }
      
      // 根据根记录类型自动切换功能模式
      const isContext = rt === 'contextSystemOptimize' || rt === 'contextUserOptimize' || rt === 'contextIterate'
      await setFunctionMode(isContext ? 'pro' : 'basic')
      
      // 调用原有的历史记录处理逻辑
      await promptHistory.handleSelectHistory(context)
    }
  }
  
  // 提示词输入标签
  const promptInputLabel = computed(() => {
    return selectedOptimizationMode.value === 'system' ? t('promptOptimizer.originalPrompt') : t('promptOptimizer.userPromptInput')
  })
  
  // 提示词输入占位符
  const promptInputPlaceholder = computed(() => {
    return selectedOptimizationMode.value === 'system' ? t('promptOptimizer.originalPromptPlaceholder') : t('promptOptimizer.userPromptPlaceholder')
  })
  
  // 真实测试处理函数
  const handleTestAreaTest = async () => {
    if (!services.value?.promptService) {
      useToast().error('服务未初始化，请稍后重试')
      return
    }
  
    if (!modelManager.selectedTestModel) {
      useToast().error('请先选择测试模型')
      return
    }
  
    console.log('[App] Starting real test with content:', testContent.value)
    
    if (isCompareMode.value) {
      // 对比模式：测试原始和优化提示词
      await Promise.all([
        testPromptWithType('original'),
        testPromptWithType('optimized')
      ])
    } else {
      // 单一模式：只测试优化后的提示词
      await testPromptWithType('optimized')
    }
  }
  
  // 测试特定类型的提示词（复用会话上下文 + 变量 + 工具）
  const testPromptWithType = async (type: 'original' | 'optimized') => {
    const isOriginal = type === 'original'
    const prompt = isOriginal ? optimizer.prompt : optimizer.optimizedPrompt
    
    if (!prompt) {
      useToast().error(isOriginal ? '请先输入原始提示词' : '请先生成优化后的提示词')
      return
    }
  
    // 设置测试状态
    if (isOriginal) {
      testResults.value.isTestingOriginal = true
      testResults.value.originalResult = ''
      testResults.value.originalReasoning = ''
    } else {
      testResults.value.isTestingOptimized = true
      testResults.value.optimizedResult = ''
      testResults.value.optimizedReasoning = ''
    }
    
    // 清除对应类型的工具调用数据
    testPanelRef.value?.clearToolCalls?.(isOriginal ? 'original' : 'optimized')
  
    try {
      const streamHandler = {
        onToken: (token: string) => {
          if (isOriginal) {
            testResults.value.originalResult += token
          } else {
            testResults.value.optimizedResult += token
          }
        },
        onReasoningToken: (reasoningToken: string) => {
          if (isOriginal) {
            testResults.value.originalReasoning += reasoningToken
          } else {
            testResults.value.optimizedReasoning += reasoningToken
          }
        },
        onComplete: () => {
          console.log(`[App] ${type} test completed`)
        },
        onError: (err: Error) => {
          const errorMessage = err.message || t('test.error.failed')
          console.error(`[App] ${type} test failed:`, errorMessage)
          useToast().error(`${type === 'original' ? '原始' : '优化'}提示词测试失败: ${errorMessage}`)
        }
      }

      // 统一构造对话与变量，尽量复用上下文
      let systemPrompt = ''
      let userPrompt = ''

      if (selectedOptimizationMode.value === 'user') {
        // 用户提示词模式：提示词作为用户输入
        systemPrompt = ''
        userPrompt = prompt
      } else {
        // 系统提示词模式：提示词作为系统消息，测试内容作为用户输入
        systemPrompt = prompt
        userPrompt = testContent.value || '请按照你的角色设定，展示你的能力并与我互动。'
      }

      const hasConversationContext = advancedModeEnabled.value && (optimizationContext.value?.length || 0) > 0
      const hasTools = advancedModeEnabled.value && (optimizationContextTools.value?.length || 0) > 0

      // 变量：合并变量库 + 当前提示词/问题（用于会话模板中的占位符）
      const baseVars = (variableManager?.variableManager.value?.resolveAllVariables() || {}) as Record<string, string>
      const variables = {
        ...baseVars,
        currentPrompt: prompt,
        userQuestion: userPrompt
      }

      // 对话：优先复用会话上下文；若无上下文则回退到 system+user 组合
      const messages = hasConversationContext
        ? optimizationContext.value.map(m => ({ role: m.role, content: m.content }))
        : [
            ...(systemPrompt ? [{ role: 'system', content: systemPrompt }] : []),
            { role: 'user', content: userPrompt }
          ]

      // 统一使用自定义会话测试，以便支持上下文与工具
      await services.value.promptService.testCustomConversationStream(
        {
          modelKey: modelManager.selectedTestModel,
          messages,
          variables,
          tools: hasTools ? optimizationContextTools.value : []
        },
        {
          ...streamHandler,
          onToolCall: (toolCall: any) => {
            if (!hasTools) return
            console.log(`[App] ${type} test tool call received:`, toolCall)
            const toolCallResult = {
              toolCall: toolCall,
              status: 'success' as const,
              timestamp: new Date()
            }
            testPanelRef.value?.handleToolCall?.(toolCallResult, type)
          },
        }
      )
  
    } catch (error: any) {
      console.error(`[App] ${type} test error:`, error)
      const errorMessage = error.message || t('test.error.failed')
      useToast().error(`${type === 'original' ? '原始' : '优化'}提示词测试失败: ${errorMessage}`)
    } finally {
      // 重置测试状态
      if (isOriginal) {
        testResults.value.isTestingOriginal = false
      } else {
        testResults.value.isTestingOptimized = false
      }
    }
  }
  
  const handleTestAreaCompareToggle = () => {
    console.log('[App] Compare mode toggled:', isCompareMode.value)
  }
  </script>
  
  <style scoped>
  /* 高级模式按钮激活状态 */
  .active-button {
    background-color: var(--primary-color, #3b82f6) !important;
    color: white !important;
    border-color: var(--primary-color, #3b82f6) !important;
  }
  
  .active-button:hover {
    background-color: var(--primary-hover-color, #2563eb) !important;
    border-color: var(--primary-hover-color, #2563eb) !important;
  }
  
  .loading-container {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    height: 100vh;
    font-size: 1.2rem;
    color: var(--text-color);
    background-color: var(--background-color);
  }
  
  .loading-container.error {
    color: #f56c6c;
  }
  
  .spinner {
    border: 4px solid rgba(128, 128, 128, 0.2);
    width: 36px;
    height: 36px;
    border-radius: 50%;
    border-left-color: var(--primary-color);
    animation: spin 1s ease infinite;
    margin-bottom: 20px;
  }
  
  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
  </style>
