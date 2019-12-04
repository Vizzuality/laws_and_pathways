import React, { useState } from "react";

const Filters = ({ tags, resultsSize }) => {
  // const [isOpen, setIsOpen] = useState(false);

  console.log('tags', tags);
  console.log('resultsSize', resultsSize)
  return (
    <div className="columns publications__menu">
      <div class="column is-10">
        <p>Showing <strong>{resultsSize}</strong> items in <strong>All Publications and news</strong></p>
      </div>
      <div className="column">
        
      </div>
    </div>
  )
}

export default Filters;
