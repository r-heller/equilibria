// overview.js — D3 force-directed tag network + linked filters for #equilibria
// Loads artifacts/graph.json, renders nodes colored by topic, edges by shared tags.
// Shift-click adds topic filter, alt-click adds tag filter.

(function() {
  'use strict';

  const TOPIC_COLORS = {
    'foundations': '#0072B2',
    'classical-games': '#E69F00',
    'evolutionary-gt': '#009E73',
    'cooperative-gt': '#56B4E9',
    'mechanism-design': '#D55E00',
    'behavioral-gt': '#CC79A7',
    'simulations': '#F0E442',
    'network-games': '#999999',
    'case-studies': '#0072B2',
    'ml-and-gt': '#E69F00',
    'auction-theory-deep-dive': '#009E73',
    'decision-theory': '#56B4E9',
    'history-of-gt-mathematics': '#D55E00',
    'cryptography-and-gt': '#CC79A7',
    'experimental-economics': '#F0E442',
    'real-world-data-applications': '#999999',
    'ethics-and-game-theory': '#0072B2',
    'ethics-applications': '#E69F00',
    'public-apis-and-datasets': '#009E73',
    'ai-ml-foundations-and-applications': '#56B4E9',
    'statistical-foundations': '#D55E00',
    'bayesian-methods': '#CC79A7',
    'optimization-numerical-methods': '#F0E442',
    'causal-inference': '#999999',
    'time-series-econometrics': '#0072B2',
    'linear-algebra-matrix': '#E69F00',
    'information-theory': '#009E73',
    'network-science': '#56B4E9',
    'behavioral-economics': '#D55E00',
    'visualization-and-communication': '#CC79A7',
    'r-package-development': '#F0E442',
    'reproducibility-open-science': '#999999'
  };

  async function init() {
    const container = document.getElementById('tag-network');
    if (!container) return;

    let data;
    try {
      const resp = await fetch('artifacts/graph.json');
      data = await resp.json();
    } catch (e) {
      container.innerHTML = '<p style="padding:2rem;text-align:center;color:var(--bs-secondary);">No tutorials published yet. The tag network will appear here once articles are added.</p>';
      return;
    }

    if (!data.nodes || data.nodes.length === 0) {
      container.innerHTML = '<p style="padding:2rem;text-align:center;color:var(--bs-secondary);">No tutorials published yet. The tag network will appear here once articles are added.</p>';
      initFilters(data);
      return;
    }

    renderNetwork(container, data);
    initFilters(data);
  }

  function renderNetwork(container, data) {
    const width = container.clientWidth;
    const height = 600;

    const svg = d3.select(container)
      .append('svg')
      .attr('width', width)
      .attr('height', height)
      .attr('viewBox', [0, 0, width, height]);

    const g = svg.append('g');

    // Zoom
    const zoom = d3.zoom()
      .scaleExtent([0.1, 4])
      .on('zoom', (event) => g.attr('transform', event.transform));
    svg.call(zoom);

    // Simulation
    const simulation = d3.forceSimulation(data.nodes)
      .force('link', d3.forceLink(data.edges).id(d => d.id).distance(80))
      .force('charge', d3.forceManyBody().strength(-120))
      .force('center', d3.forceCenter(width / 2, height / 2))
      .force('collision', d3.forceCollide().radius(8));

    // Edges
    const link = g.append('g')
      .selectAll('line')
      .data(data.edges)
      .join('line')
      .attr('stroke', '#ccc')
      .attr('stroke-opacity', 0.4)
      .attr('stroke-width', d => Math.min(d.weight || 1, 4));

    // Nodes
    const node = g.append('g')
      .selectAll('circle')
      .data(data.nodes)
      .join('circle')
      .attr('r', 5)
      .attr('fill', d => TOPIC_COLORS[d.topic] || '#999')
      .attr('stroke', '#fff')
      .attr('stroke-width', 1)
      .style('cursor', 'pointer')
      .call(drag(simulation));

    // Tooltips
    node.append('title')
      .text(d => d.title);

    // Click: open tutorial
    node.on('click', (event, d) => {
      if (event.shiftKey) {
        addTopicFilter(d.topic);
      } else if (event.altKey) {
        addTagFilter(d.tags);
      } else if (d.url) {
        window.location.href = d.url;
      }
    });

    simulation.on('tick', () => {
      link
        .attr('x1', d => d.source.x)
        .attr('y1', d => d.source.y)
        .attr('x2', d => d.target.x)
        .attr('y2', d => d.target.y);

      node
        .attr('cx', d => d.x)
        .attr('cy', d => d.y);
    });

    // Reset zoom button
    const resetBtn = document.querySelector('[href="#tag-network"]');
    if (resetBtn) {
      resetBtn.addEventListener('click', (e) => {
        e.preventDefault();
        svg.transition().duration(500).call(zoom.transform, d3.zoomIdentity);
      });
    }
  }

  function drag(simulation) {
    return d3.drag()
      .on('start', (event, d) => {
        if (!event.active) simulation.alphaTarget(0.3).restart();
        d.fx = d.x;
        d.fy = d.y;
      })
      .on('drag', (event, d) => {
        d.fx = event.x;
        d.fy = event.y;
      })
      .on('end', (event, d) => {
        if (!event.active) simulation.alphaTarget(0);
        d.fx = null;
        d.fy = null;
      });
  }

  // --- Filters ---
  const activeFilters = { topics: new Set(), tags: new Set(), search: '' };

  function initFilters(data) {
    const controls = document.getElementById('filter-controls');
    if (!controls) return;

    // Collect all topics and tags
    const topics = [...new Set(data.nodes.map(n => n.topic).filter(Boolean))].sort();
    const tags = [...new Set(data.nodes.flatMap(n => n.tags || []))].sort();

    let html = '<input id="search-box" placeholder="Search tutorials…" style="width:100%;padding:0.5rem;margin-bottom:1rem;border:1px solid var(--bs-border-color);border-radius:0.25rem;" />';
    html += '<div id="topic-chips" style="margin-bottom:0.5rem;">';
    topics.forEach(t => {
      html += `<span class="filter-chip" data-type="topic" data-value="${t}">${t}</span> `;
    });
    html += '</div>';
    html += '<div id="tag-chips">';
    tags.forEach(t => {
      html += `<span class="filter-chip" data-type="tag" data-value="${t}">${t}</span> `;
    });
    html += '</div>';

    controls.innerHTML = html;

    // Wire up events
    controls.querySelectorAll('.filter-chip').forEach(chip => {
      chip.addEventListener('click', () => {
        chip.classList.toggle('active');
        const type = chip.dataset.type;
        const value = chip.dataset.value;
        const set = type === 'topic' ? activeFilters.topics : activeFilters.tags;
        if (chip.classList.contains('active')) {
          set.add(value);
        } else {
          set.delete(value);
        }
        applyFilters(data);
      });
    });

    const searchBox = document.getElementById('search-box');
    if (searchBox) {
      searchBox.addEventListener('input', (e) => {
        activeFilters.search = e.target.value.toLowerCase();
        applyFilters(data);
      });
    }

    // Initial list render
    renderTutorialList(data.nodes);
  }

  function applyFilters(data) {
    const filtered = data.nodes.filter(n => {
      if (activeFilters.search && !n.title.toLowerCase().includes(activeFilters.search)) return false;
      if (activeFilters.topics.size > 0 && !activeFilters.topics.has(n.topic)) return false;
      if (activeFilters.tags.size > 0) {
        const nTags = n.tags || [];
        if (!nTags.some(t => activeFilters.tags.has(t))) return false;
      }
      return true;
    });

    // Fade non-matching nodes in the graph
    d3.selectAll('#tag-network circle')
      .attr('opacity', d => {
        const match = filtered.some(f => f.id === d.id);
        return match ? 1 : 0.1;
      });

    d3.selectAll('#tag-network line')
      .attr('opacity', 0.15);

    renderTutorialList(filtered);
  }

  function renderTutorialList(nodes) {
    const list = document.getElementById('tutorial-list');
    if (!list) return;

    if (nodes.length === 0) {
      list.innerHTML = '<p>No matching tutorials found.</p>';
      return;
    }

    const sorted = [...nodes].sort((a, b) => a.title.localeCompare(b.title));
    let html = '<ul style="list-style:none;padding:0;">';
    sorted.forEach(n => {
      html += `<li style="padding:0.25rem 0;"><a href="${n.url}">${n.title}</a> <small style="color:var(--bs-secondary);">${n.topic}</small></li>`;
    });
    html += '</ul>';
    list.innerHTML = html;
  }

  function addTopicFilter(topic) {
    activeFilters.topics.add(topic);
    const chip = document.querySelector(`.filter-chip[data-value="${topic}"]`);
    if (chip) chip.classList.add('active');
  }

  function addTagFilter(tags) {
    if (!tags) return;
    tags.forEach(t => {
      activeFilters.tags.add(t);
      const chip = document.querySelector(`.filter-chip[data-value="${t}"]`);
      if (chip) chip.classList.add('active');
    });
  }

  document.addEventListener('DOMContentLoaded', init);
})();
