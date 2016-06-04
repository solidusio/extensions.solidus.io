function createStickyHeader(target) {
  var stickyHeader = document.createElement('div');
  var cloneRow = document.createElement('div');
  var targetRect = target.getBoundingClientRect();
  stickyHeader.classList.add('sticky-header');
  stickyHeader.style.height = targetRect.height;
  stickyHeader.appendChild(cloneRow);
  cloneRow.classList.add('tr');
  cloneRow.style.left = targetRect.left;
  cloneRow.style.width = targetRect.width;
  Array.prototype.forEach.call(target.children, function(th, i){
    var fakeHeader = document.createElement('div');
    var thRect = th.getBoundingClientRect();
    fakeHeader.classList.add('th');
    fakeHeader.innerHTML = th.innerHTML;
    fakeHeader.style.cssText = document.defaultView.getComputedStyle(th, "").cssText;
    fakeHeader.style.position = 'absolute';
    fakeHeader.style.left = thRect.left - targetRect.left;
    cloneRow.appendChild(fakeHeader);
  });
  document.body.appendChild(stickyHeader);
  return stickyHeader;
}

var stickyTarget = document.querySelector('[data-sticky-header]');
var stickyClone = createStickyHeader(stickyTarget);

var stickyHeaderToggle = function() {
  this.targetTop = this.targetTop || stickyTarget.getBoundingClientRect().top + document.body.scrollTop;
  if(document.body.scrollTop >= this.targetTop) {
    stickyClone.classList.remove('hide')
  } else {
    stickyClone.classList.add('hide')
  }
};

window.addEventListener('scroll', stickyHeaderToggle);
stickyHeaderToggle();
