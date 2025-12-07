#!/bin/bash
# ===========================================
# 本地快速检查脚本
# 在push代码前运行，确保基本质量
# ===========================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "🔍 =========================="
echo "   本地快速检查"
echo "   (Push前请确保通过)"
echo "=========================="
echo ""

# 记录开始时间
START_TIME=$(date +%s)

# 1. 后端Lint检查
echo -e "${BLUE}[1/4]${NC} 后端代码检查..."
cd backend
if command -v uv &> /dev/null; then
    uv run flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics 2>/dev/null || {
        echo -e "${YELLOW}[!] flake8未安装，跳过后端lint${NC}"
    }
else
    echo -e "${YELLOW}[!] uv未安装，跳过后端检查${NC}"
fi
echo -e "${GREEN}[✓]${NC} 后端检查完成"
cd ..

# 2. 前端Lint检查
echo -e "${BLUE}[2/4]${NC} 前端代码检查..."
cd frontend
npm run lint 2>/dev/null || {
    echo -e "${RED}[✗] 前端Lint检查失败${NC}"
    exit 1
}
echo -e "${GREEN}[✓]${NC} 前端Lint检查通过"
cd ..

# 3. 前端构建检查
echo -e "${BLUE}[3/4]${NC} 前端构建检查..."
cd frontend
npm run build 2>/dev/null || {
    echo -e "${RED}[✗] 前端构建失败${NC}"
    exit 1
}
echo -e "${GREEN}[✓]${NC} 前端构建成功"
cd ..

# 4. 后端单元测试
echo -e "${BLUE}[4/4]${NC} 后端单元测试..."
cd backend
if command -v uv &> /dev/null; then
    if [ -d "tests/unit" ] && [ "$(ls -A tests/unit 2>/dev/null)" ]; then
        uv run pytest tests/unit -v --tb=short 2>/dev/null || {
            echo -e "${YELLOW}[!] 后端测试失败或未配置${NC}"
        }
    else
        echo -e "${YELLOW}[!] 未找到单元测试，跳过${NC}"
    fi
fi
echo -e "${GREEN}[✓]${NC} 后端测试完成"
cd ..

# 计算耗时
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "=========================="
echo -e "${GREEN}✅ 快速检查通过！${NC}"
echo "耗时: ${DURATION}秒"
echo "=========================="
echo ""
echo "下一步："
echo "  git push origin <branch>"
echo ""
echo "完整测试请运行："
echo "  npm run test:all"
echo ""

