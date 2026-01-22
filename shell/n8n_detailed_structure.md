# n8n 结构模块详细说明

## 1. 项目总体结构

```
n8n/
├── packages/
│   ├── cli/                 # 后端主服务
│   ├── core/                # 核心功能模块
│   ├── editor-ui/           # 前端用户界面
│   ├── nodes-base/          # 基础节点集合
│   ├── workflow/            # 工作流引擎
│   ├── request/             # 请求处理模块
│   └── cli-worker/          # 工作进程
├── docker/                  # Docker 配置
├── pm2/                     # PM2 进程管理配置
├── scripts/                 # 构建和开发脚本
└── docs/                    # 项目文档
```

## 2. 后端模块

### 2.1 packages/cli/ - 后端主服务

- **路径**: `packages/cli/`
- **功能**:
  - n8n 的命令行界面
  - 启动和管理 n8n 实例
  - 处理工作流执行
  - 提供 REST API 接口
  - 管理用户认证和权限
- **主要文件**:
  - `bin/n8n` - 可执行文件入口
  - `src/commands/` - CLI 命令实现
  - `src/Server.ts` - 主服务器实现
  - `src/credentials/` - 凭证管理
  - `src/databases/` - 数据库配置

### 2.2 packages/core/ - 核心功能模块

- **路径**: `packages/core/`
- **功能**:
  - 提供基础抽象
  - 节点类型定义
  - 表达式引擎
  - 凭证管理系统
  - 工作流执行辅助函数
- **主要文件**:
  - `NodeExecuteFunctions.ts` - 节点执行函数
  - `Workflow.ts` - 工作流核心逻辑
  - `Credentials.ts` - 凭证管理系统
  - `Expression.ts` - 表达式引擎

### 2.3 packages/workflow/ - 工作流引擎

- **路径**: `packages/workflow/`
- **功能**:
  - 定义工作流结构
  - 处理节点关系
  - 执行逻辑管理
- **主要文件**:
  - `Workflow.ts` - 工作流类定义
  - `Interfaces.ts` - 核心接口定义
  - `NodeHelpers.ts` - 节点辅助函数

### 2.4 packages/cli-worker/ - 工作进程

- **路径**: `packages/cli-worker/`
- **功能**:
  - 在单独进程中执行工作流
  - 提供更好的隔离性和性能
  - 处理长时间运行的任务

## 3. 前端模块

### 3.1 packages/editor-ui/ - 前端用户界面

- **路径**: `packages/editor-ui/`
- **功能**:
  - 提供可视化工作流编辑器
  - 允许用户拖拽节点
  - 配置参数和调试工作流
  - 显示工作流执行历史
- **技术栈**: Vue.js, TypeScript, Element UI
- **主要目录**:
  - `src/views/` - 主要页面视图
  - `src/components/` - 可复用组件
  - `src/stores/` - 状态管理 (Pinia)
  - `src/api/` - API 调用接口
  - `src/composables/` - 组合式 API 函数

### 3.2 前端端口配置

- **默认端口**: 5678
- **配置方式**:
  1. 通过环境变量: `N8N_EDITOR_UI_PORT=5678`
  2. 通过命令行参数: `n8n --editor-ui-port=5678`
  3. 在配置文件中设置: `~/.n8n/config`
- **前端访问地址**: `http://localhost:5678`

## 4. 数据库模块

### 4.1 数据库支持

n8n 支持以下数据库系统：

- SQLite (默认，适合小型部署)
- MySQL
- PostgreSQL

### 4.2 数据库配置

- **配置路径**: `packages/cli/src/databases/`
- **主要配置文件**:
  - `config/db.config.ts` - 数据库连接配置
  - `entities/` - 实体定义
  - `migrations/` - 数据库迁移脚本

### 4.3 后端数据库配置方法

#### 4.3.1 环境变量配置

```bash
# SQLite (默认)
N8N_DATABASE_TYPE=sqlite

# MySQL
N8N_DATABASE_TYPE=mysql
DB_MYSQL_HOST=localhost
DB_MYSQL_PORT=3306
DB_MYSQL_DATABASE=n8n
DB_MYSQL_USER=n8n
DB_MYSQL_PASSWORD=password

# PostgreSQL
N8N_DATABASE_TYPE=postgresdb
DB_POSTGRES_HOST=localhost
DB_POSTGRES_PORT=5432
DB_POSTGRES_DATABASE=n8n
DB_POSTGRES_USER=n8n
DB_POSTGRES_PASSWORD=password
```

#### 4.3.2 配置文件设置

在 `~/.n8n/config` 文件中添加：

```json
{
  "database": {
    "type": "mysql",
    "mysql": {
      "host": "localhost",
      "port": 3306,
      "database": "n8n",
      "user": "n8n",
      "password": "password"
    }
  }
}
```

#### 4.3.3 命令行配置

```bash
n8n --db-type mysql --db-mysql-host localhost --db-mysql-port 3306
```

### 4.4 存储的数据类型

- 工作流定义和配置
- 用户凭证和密钥
- 工作流执行历史
- 用户账户信息
- 设置和配置信息
- 通知和日志数据

## 5. 其他模块

### 5.1 packages/nodes-base/ - 基础节点集合

- **路径**: `packages/nodes-base/`
- **功能**: 提供大量内置节点，用于连接各种服务和执行不同任务
- **示例节点**:
  - HTTP Request - 发送 HTTP 请求
  - Function - 执行 JavaScript 代码
  - Code - 执行 TypeScript 代码
  - 各种服务集成节点 (Google Sheets, Slack, Email 等)

### 5.2 packages/request/ - 请求处理模块

- **路径**: `packages/request/`
- **功能**: 处理 HTTP 请求，提供安全的 API 访问

## 6. 运行模式

### 6.1 主模式 (Main Mode)

- 同时处理 API 请求和工作流执行
- 适用于小型部署

### 6.2 队列模式 (Queue Mode)

- 使用消息队列处理工作流
- 适用于高负载环境
- 通常与 Redis 配合使用

### 6.3 工作者模式 (Worker Mode)

- 专门执行工作流
- 与主服务分离，提高安全性
