# n8n 项目结构说明

n8n 是一个开源的工作流程自动化平台，允许用户通过可视化界面连接各种应用和服务。以下是对 n8n 项目结构的详细说明：

## 根目录结构

- `package.json` - 项目配置文件，包含项目元数据、依赖项和脚本命令
- `tsconfig.json` - TypeScript 配置文件
- `turbo.json` - Turbo 构建系统的配置文件，用于管理构建缓存和并行执行
- `.gitignore` - Git 忽略文件配置
- `.npmrc` - npm 配置文件
- `README.md` - 项目说明文档

## 主要目录结构

### packages/

这是 n8n 的核心目录，采用 monorepo 结构，包含多个相互关联的包：

#### packages/cli/

- **功能**: n8n 的命令行界面，负责启动和管理 n8n 实例
- **作用**: 提供 n8n 的核心运行环境，处理工作流执行、API 请求等
- **主要文件**:
  - `bin/n8n` - n8n 可执行文件入口
  - `src/commands/` - CLI 命令实现
  - `src/Server.ts` - 主服务器实现

#### packages/core/

- **功能**: n8n 的核心功能模块
- **作用**: 提供基础抽象、节点类型定义、表达式引擎、凭证管理等
- **主要模块**:
  - `NodeExecuteFunctions.ts` - 节点执行函数
  - `Workflow.ts` - 工作流核心逻辑
  - `Credentials.ts` - 凭证管理系统
  - `Expression.ts` - 表达式引擎

#### packages/editor-ui/

- **功能**: n8n 的前端用户界面
- **作用**: 提供可视化工作流编辑器，允许用户拖拽节点、配置参数、调试工作流
- **技术栈**: Vue.js
- **主要目录**:
  - `src/views/` - 主要页面视图
  - `src/components/` - 可复用组件
  - `src/stores/` - 状态管理 (Pinia)

#### packages/nodes-base/

- **功能**: n8n 的基础节点集合
- **作用**: 提供大量内置节点，用于连接各种服务和执行不同任务
- **示例节点**:
  - HTTP Request - 发送 HTTP 请求
  - Function - 执行 JavaScript 代码
  - Code - 执行 TypeScript 代码
  - 各种服务集成节点 (Google Sheets, Slack, Email 等)

#### packages/workflow/

- **功能**: 工作流引擎的核心逻辑
- **作用**: 定义工作流结构、节点关系、执行逻辑等
- **主要模块**:
  - `Workflow.ts` - 工作流类定义
  - `Interfaces.ts` - 核心接口定义
  - `NodeHelpers.ts` - 节点辅助函数

#### packages/request/

- **功能**: n8n 的请求处理模块
- **作用**: 处理 HTTP 请求，提供安全的 API 访问

#### packages/cli-worker/

- **功能**: n8n 的工作进程
- **作用**: 在单独进程中执行工作流，提供更好的隔离性和性能

### other/

包含一些辅助工具和文档：

- `docker/` - Docker 相关配置
- `pm2/` - PM2 进程管理配置
- `scripts/` - 构建和开发脚本

### docs/

- **功能**: 项目文档
- **作用**: 包含使用指南、API 文档、开发者文档等

## 关键概念

### 节点 (Nodes)

- 工作流的基本构建块
- 每个节点代表一个特定的操作或服务
- 节点可以通过不同方式连接形成工作流

### 工作流 (Workflows)

- 由多个节点组成的自动化流程
- 定义数据如何在节点间流动
- 可以通过触发器启动

### 凭证 (Credentials)

- 存储服务访问凭据的安全机制
- 支持加密存储 API 密钥、用户名密码等

### 触发器 (Triggers)

- 启动工作流的特殊节点
- 可以是定时触发、Webhook、事件监听等

## 技术栈

- **后端**: Node.js, TypeScript
- **前端**: Vue.js, TypeScript, Element UI
- **数据库**: 支持 SQLite, MySQL, PostgreSQL
- **构建工具**: Turbo, TypeScript, Rollup
- **测试框架**: Jest

## 开发模式

n8n 支持多种运行模式：

- **主模式**: 运行完整的 n8n 实例
- **工作者模式**: 仅执行工作流
- **队列模式**: 使用消息队列处理工作流

这种架构使得 n8n 具有高度的可扩展性和灵活性，能够处理从小型个人自动化到企业级复杂工作流的各种场景。
