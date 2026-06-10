const products = [
  {id:1,name:'Handmade Mug',price:18.99,img:'https://picsum.photos/seed/mug/400/300'},
  {id:2,name:'Organic Tea',price:9.5,img:'https://picsum.photos/seed/tea/400/300'},
  {id:3,name:'Canvas Tote',price:22.0,img:'https://picsum.photos/seed/tote/400/300'},
  {id:4,name:'Wool Scarf',price:34.0,img:'https://picsum.photos/seed/scarf/400/300'},
  {id:5,name:'Scented Candle',price:14.5,img:'https://picsum.photos/seed/candle/400/300'},
  {id:6,name:'Notebook',price:7.75,img:'https://picsum.photos/seed/notebook/400/300'}
];

function fmt(n){return '$'+n.toFixed(2)}

const grid = document.getElementById('product-grid');
products.forEach(p=>{
  const el = document.createElement('article');
  el.className = 'card';
  el.innerHTML = `
    <img src="${p.img}" alt="${p.name}">
    <h3>${p.name}</h3>
    <div class="meta">Small-batch favorite</div>
    <div class="price">${fmt(p.price)}</div>
    <div class="actions">
      <button class="btn buy">Add to cart</button>
      <button class="btn ghost">View</button>
    </div>
  `;
  el.querySelector('.buy').addEventListener('click', ()=>{
    alert(`${p.name} added to cart — ${fmt(p.price)}`);
  });
  grid.appendChild(el);
});

document.getElementById('year').textContent = new Date().getFullYear();
