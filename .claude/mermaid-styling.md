# Mermaid Graph Styling Rules

## High-Contrast Color Scheme

All mermaid graphs in CIM documentation must use this standardized high-contrast color scheme for consistency and accessibility.

### Color Palette

#### 1. Primary/Important Elements (Red)
- **Fill**: `#FF6B6B` (coral red)
- **Stroke**: `#C92A2A` (dark red)
- **Text**: `#FFF` (white)
- **Stroke Width**: `3-4px`
- **Use for**: Main components, core traits, error sources, critical paths, admin access

#### 2. Secondary Elements (Teal)
- **Fill**: `#4ECDC4` (turquoise)
- **Stroke**: `#2B8A89` (dark teal)
- **Text**: `#FFF` (white)
- **Stroke Width**: `2-3px`
- **Use for**: Storage layers, middleware, processing stages, SQL/IPLD storage

#### 3. Choice/Decision Points (Yellow)
- **Fill**: `#FFE66D` (bright yellow)
- **Stroke**: `#FCC419` (golden yellow)
- **Text**: `#000` (black)
- **Stroke Width**: `2-3px`
- **Use for**: Query systems, filters, decision nodes, warm storage, medium priority

#### 4. Results/Outcomes (Light Green)
- **Fill**: `#95E1D3` (mint green)
- **Stroke**: `#63C7B8` (medium teal green)
- **Text**: `#000` (black)
- **Stroke Width**: `2-3px`
- **Use for**: Final outputs, successful outcomes, memory storage, fast operations

#### 5. Start/Root Nodes (Dark Gray)
- **Fill**: `#2D3436` (charcoal)
- **Stroke**: `#000` (black)
- **Text**: `#FFF` (white)
- **Stroke Width**: `3px`
- **Use for**: Entry points, initial states, user inputs, base queries

### Style Template

```mermaid
graph TB
    %% Primary Elements
    style PrimaryNode fill:#FF6B6B,stroke:#C92A2A,stroke-width:4px,color:#FFF
    
    %% Secondary Elements
    style SecondaryNode fill:#4ECDC4,stroke:#2B8A89,stroke-width:3px,color:#FFF
    
    %% Choice/Decision Points
    style ChoiceNode fill:#FFE66D,stroke:#FCC419,stroke-width:3px,color:#000
    
    %% Results/Outcomes
    style ResultNode fill:#95E1D3,stroke:#63C7B8,stroke-width:2px,color:#000
    
    %% Start/Root Nodes
    style StartNode fill:#2D3436,stroke:#000,stroke-width:3px,color:#FFF
```

### Usage Guidelines

1. **Consistency**: Apply the same color to nodes with similar semantic meaning across all diagrams
2. **Hierarchy**: Use stroke width to indicate importance (4px > 3px > 2px)
3. **Contrast**: Ensure text color provides sufficient contrast with background
4. **Accessibility**: These colors are chosen for high contrast and colorblind accessibility

### Example Application

```mermaid
graph LR
    Start[User Request] --> API[API Layer]
    API --> Process{Process Type?}
    Process -->|Query| Query[Query Engine]
    Process -->|Store| Store[Storage Layer]
    Query --> Result[Query Results]
    Store --> Result[Store Confirmation]
    
    style Start fill:#2D3436,stroke:#000,stroke-width:3px,color:#FFF
    style API fill:#FF6B6B,stroke:#C92A2A,stroke-width:4px,color:#FFF
    style Process fill:#FFE66D,stroke:#FCC419,stroke-width:3px,color:#000
    style Query fill:#4ECDC4,stroke:#2B8A89,stroke-width:3px,color:#FFF
    style Store fill:#4ECDC4,stroke:#2B8A89,stroke-width:3px,color:#FFF
    style Result fill:#95E1D3,stroke:#63C7B8,stroke-width:2px,color:#000
```

### Semantic Color Mapping

- **Red (#FF6B6B)**: Commands, errors, critical components, primary APIs
- **Teal (#4ECDC4)**: Events, storage, middleware, secondary operations
- **Yellow (#FFE66D)**: Choices, filters, conditions, medium priority
- **Green (#95E1D3)**: Success, results, outcomes, optimized paths
- **Gray (#2D3436)**: Start states, user input, root nodes

### Notes

- Always include style definitions at the end of your mermaid blocks
- Group related nodes with the same styling for visual coherence
- Use subgraphs sparingly as they can interfere with styling
- Test graphs in both light and dark themes to ensure readability