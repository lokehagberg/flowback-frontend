# Ensure all necessary imports
import networkx as nx
from networkx.algorithms.community import greedy_modularity_communities
import os
import re
import matplotlib.pyplot as plt


# Function to extract module names and build a graph (reused from previous cells)
def get_module_name(file_path, root_dir):
    """Convert a Svelte file path to a module name."""
    relative_path = os.path.relpath(file_path, root_dir).replace(os.sep, "/")
    # Remove the .svelte extension
    return re.sub(r"\.svelte$", "", relative_path)


def extract_imports(file_path):
    """Extract imported modules from a Svelte file."""
    imports = set()
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
        # Match Svelte import patterns
        patterns = [
            r'import\s+.*?from\s+[\'"]([^\'"\s]+)[\'"]',  # all imports with from
            r'import\s+[\'"]([^\'"\s]+)[\'"]',            # direct imports
        ]
        for pattern in patterns:
            for imported in re.findall(pattern, content):
                if imported.startswith('./') or imported.startswith('../') or imported.startswith('$'):
                    imports.add(imported)
    return imports

def normalize_import_path(import_path, source_dir):
    """Normalize relative import paths."""
    if import_path.startswith('$'):
        # Handle aliased imports (customize this based on your svelte.config.js)
        return import_path.replace('$lib/', 'src/lib/')
    
    # Convert relative path to absolute
    abs_path = os.path.normpath(os.path.join(source_dir, import_path))
    # Convert back to relative path from project root
    return os.path.relpath(abs_path, project_root).replace('\\', '/')


def build_dependency_graph(root_dir):
    """Build a directed graph of Svelte component dependencies."""
    G = nx.DiGraph()
    svelte_files = []
    
    print("Scanning for Svelte files...")
    for root, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.svelte'):
                full_path = os.path.join(root, file)
                svelte_files.append(full_path)
                module = get_module_name(full_path, root_dir)
                G.add_node(module)
                print(f"Found component: {module}")

    print(f"\nAnalyzing dependencies for {len(svelte_files)} components...")
    for file_path in svelte_files:
        source_module = get_module_name(file_path, root_dir)
        source_dir = os.path.dirname(file_path)
        
        imports = extract_imports(file_path)
        print(f"\nComponent {source_module} imports:")
        for imported in imports:
            normalized_import = normalize_import_path(imported, source_dir)
            # Try different possible extensions
            possible_paths = [
                f"{normalized_import}.svelte",
                f"{normalized_import}/index.svelte",
                normalized_import
            ]
            
            for possible_path in possible_paths:
                target_module = re.sub(r"\.svelte$", "", possible_path)
                if target_module in G.nodes:
                    G.add_edge(source_module, target_module)
                    print(f"  - {imported} -> {target_module}")
                    break

    return G, svelte_files


# Rebuild the graph if it doesn't exist
if 'G' not in locals() or 'G' not in globals() or 'svelte_files' not in locals() or 'svelte_files' not in globals():
    project_root = "."  # Define the project root directory
    G, svelte_files = build_dependency_graph(project_root)

# Calculate and display modularity
if G.nodes:
    print(f"\nTotal number of modules (Svelte components): {len(G.nodes)}")
    if G.number_of_edges() == 0:
        print("No dependencies found between modules. Cannot calculate modularity for a graph without edges.")
    else:
        # Calculate communities and modularity score
        communities = list(greedy_modularity_communities(G.to_undirected()))
        modularity_score = nx.algorithms.community.modularity(G.to_undirected(), communities)

        print(f"Number of edges (dependencies): {G.number_of_edges()}")
        print(f"Number of communities detected: {len(communities)}")
        print(f"Modularity Score: {modularity_score:.3f}")
        print("Modularity measures how well the system can be divided into independent communities. "
              "Higher modularity indicates better separation of components, leading to improved maintainability.")

        # Visualize communities
        community_colors = {node: idx for idx, community in enumerate(communities) for node in community}
        node_colors = [community_colors[node] for node in G.nodes()]

        plt.figure(figsize=(12, 10))
        pos = nx.spring_layout(G)  # Layout for visualization
        nx.draw(G, pos, with_labels=True, node_color=node_colors, cmap=plt.cm.tab10,
                edge_color='gray', node_size=300, font_size=8, alpha=0.8)
        plt.title("Community Visualization of Svelte Component Dependencies")
        plt.tight_layout()
        plt.show()
else:
    print("No Svelte components found. The graph is empty.")
